require 'progress_bar'
require 'oai'
require 'libxml'

class OaiImporter
  attr_accessor :client

  LOGGER = Logger.new(Rails.root.join('log', 'oai_importer.log'), 10, 1_024_000)

  def initialize(opts = {})
    @url = opts[:url]
    @image_url = opts[:image_url]
    @user = User.find_by_email(opts[:user_email])
    @headers = opts[:headers]
    @test = opts[:test]
    @work_factory = OaiWorkFactory.new(@user)
    @collection_factory = OaiCollectionFactory.new(@user)
    @work_factory.collection_factory = @collection_factory
    @client = OAI::Client.new(@url, headers: @headers, parser: 'libxml', metadata_prefix: 'mods')
  end

  def process
    bar
    if @test
      loop_first_page_of_records { |record| process_record(record) }
    else
      loop_all_records { |record| process_record(record) }
    end
    # Trigger index of all the collections since we've been skipping them
    Collection.do_index = true
    puts 'indexing collections'
    @collection_factory.collections.each do |key, value|
      value.save
    end
  end

  def response
    @response ||= client.list_records
  end

  def bar
    return @bar if @bar
    number = @test.present? ? 100 : response.doc.find('.//resumptionToken').to_a.first.attributes['completeListSize'].to_i
    @bar = ProgressBar.new(number)
  end

  def loop_all_records(&block)
    response.full.each(&block)
  end

  def loop_first_page_of_records(&block)
    response.each(&block)
  end

  def process_record(record)
    parsed_record = OaiRecordParser.new(record, @image_url)
    @work_factory.build(parsed_record.all_attrs)
    bar.increment!
  end
end

class OaiRecordParser
  attr_accessor :record
  def initialize(record, image_url)
    @image_url = image_url
    @record = record
  end

  def all_attrs
    merge_attrs(header, metadata)
  end

  def header
    { 'thumbnail_url' => ["#{@image_url}?cover=#{record.header.identifier.split(':').last}&size=L"] }
  end

  def metadata
    return @metadata if @metadata
    @metadata = record.metadata&.child&.children&.each_with_object({}) do |node, hash|
      case node.name
      when 'format'
        hash['format_original'] ||= []
        hash['format_original'] << node.content
      when 'coverage'
        hash['place'] ||= []
        hash['place'] << node.content
      when 'relation'
        hash['collection'] ||= []
        hash['collection'] << node.content
      when 'type'
        hash['types'] ||= []
        hash['types'] << node.content
      when 'rights'
        next
      else
        hash[node.name] ||= []
        hash[node.name] << node.content
      end
    end
    if @metadata
      @metadata['contributing_institution'] = ['Princeton Theological Seminary Library']
      @metadata['rights'] = ['Copyright Not Evaluated. The copyright and related rights status of this Item has not been evaluated. Please refer to the organization that has made the Item available for more information. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. <a href="http://rightsstatements.org/vocab/CNE/1.0/" target="_blank">http://rightsstatements.org/vocab/CNE/1.0/</a>']
    end
    @metadata
  end

  def merge_attrs(first, second)
    return first if second.blank?
    first = {} if first.blank?
    first.merge(second) do |key, old, new|
      if key =~ /identifier/
        merged_value = old if old.first =~ /^http/
        merged_value = new if new.first =~ /^http/
      else
        merged_value = old + new
      end
      merged_value
    end
  end
end

class OaiWorkFactory
  attr_accessor :collection_factory

  def initialize(user)
    @user = user
    @valid_attrs = Work.new.attributes.keys
  end

  def self.admin_set_id
    @@admin_set_id ||= AdminSet.first.id
  end

  def build(attrs)
    if self.existing_work?(attrs['identifier'])
      OaiImporter::LOGGER.info("skipping exisitng work with identifier: #{attrs['identifier']}")
      return
    end
    collection = collection_factory.build('title' => attrs['collection'])
    work = Work.new
    clean_attrs(attrs).each do |key, value|
      work.send("#{key}=", value)
    end
    work.apply_depositor_metadata(@user.user_key)
    work.visibility = 'open'
    work.admin_set_id = OaiWorkFactory.admin_set_id
    if work.save
      if collection.present?
        collection.add_members([work.id])
        collection.save
      end
      add_image(attrs['thumbnail_url'].first, work)
      OaiImporter::LOGGER.info("created work with title: #{attrs['title'].try(:first)} and id: #{work.id}")
    else
      OaiImporter::LOGGER.error("Failed to create Work with title: #{attrs['title'].try(:first)} and Identifier: #{attrs['identifier']}, error messages: #{work.try(:errors).try(:messages)}")
    end
    work
  end

  def existing_work?(identifier)
    Work.where(identifier: identifier).present?
  end

  def add_image(url, work)
    open(url) do |f|
      uploaded_file = Sufia::UploadedFile.create(file: f, user: @user)
      file_set = FileSet.new
      file_set.visibility = 'open'
      actor = CurationConcerns::Actors::FileSetActor.new(file_set, @user)
      actor.create_metadata(work, visibility: work.visibility) do |file|
        file.permissions_attributes = work.permissions.map(&:to_hash)
      end
      actor.create_content(uploaded_file.file.file)
      uploaded_file.update(file_set_uri: file_set.uri)
    end
  rescue
    OaiImporter::LOGGER.error("Failed to add image url (#{url}) to work with identifier #{work.identifier}")
  end

  def clean_attrs(attrs)
    @valid_attrs.each_with_object({}) do |attr_name, hash|
      hash[attr_name] = attrs[attr_name] if attrs[attr_name].present?
    end
  end
end

class OaiCollectionFactory
  attr_accessor :default_collection_name, :collections
  def initialize(user)
    @user = user
    @valid_attrs = Collection.new.attributes.keys
  end

  def build(attrs)
    return if attrs['title'].blank?
    existing_collection = get_collection(attrs['title'])
    if existing_collection.present?
      existing_collection
      Collection.do_index = false
    else
      Collection.do_index = true
      collection = Collection.new
      clean_attrs(attrs).each do |key, value|
        collection.send("#{key}=", value)
      end
      collection.apply_depositor_metadata(@user.user_key)
      collection.visibility = 'open'
      collection.save
      OaiImporter::LOGGER.info("Created collection with title: #{attrs['title'].try(:first)} and id: #{collection.id}")
      collection
    end
  end

  def get_collection(title)
    collections[title] ||= Collection.where(title: title).first
  end

  def collections
    @collections ||= {}
  end

  def clean_attrs(attrs)
    @valid_attrs.each_with_object({}) do |attr_name, hash|
      hash[attr_name] = attrs[attr_name] if attrs[attr_name].present?
    end
  end
end
