require 'progress_bar'
require 'oai'
require 'libxml'

module Atla
  class OaiImporter
    attr_accessor :client

    LOGGER = Logger.new(Rails.root.join('log', 'oai_importer.log'), 10, 1_024_000)

    def initialize(opts = {})
      @url = opts[:url]
      @image_url = opts[:image_url]
      @default_collection_name = opts[:default_collection_name]
      @user = User.find_by_email(opts[:user_email])
      @name = opts[:name]
      @headers = opts[:headers]
      @test = opts[:test]
      @work_factory = OaiWorkFactory.new(@user)
      @collection_factory = OaiCollectionFactory.new(@user, @default_collection_name)
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
    end

    def response
      @response ||= client.list_records
    end

    def bar
      @bar ||= ProgressBar.new(response.doc.find('.//resumptionToken').to_a.first.attributes['completeListSize'].to_i)
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
      merge_attrs(merge_attrs(header, metadata), about)
    end

    def header
      return @header if @header
      set_spec = record.header.set_spec.each_with_object({}) do |node, hash|
        content = node.content.split(':')
        hash[content.first] = content[1..-1]
      end
      url = "#{@image_url}?cover=#{record.header.identifier.split(':').last}&size=L"
      @header = {
        'identifier' => [record.header.identifier],
        'date' => [record.header.datestamp],
        'set_spec' => record.header.set_spec.map(&:content),
        'thumbnail_url' => [url]
      }.merge(set_spec)
    end

    def metadata
      @metadata ||= record.metadata&.child&.children&.each_with_object({}) do |node, hash|
        hash[node.name] ||= []
        hash[node.name] << node.content
      end
    end

    def about
      @about ||= record.about&.child&.children&.each_with_object({}) do |node, hash|
        hash[node.name] ||= []
        hash[node.name] << node.content
      end
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

    def build(attrs)
      collection = collection_factory.build('title' => attrs['collection'])
      work = Work.new
      clean_attrs(attrs).each do |key, value|
        work.send("#{key}=", value)
      end
      work.apply_depositor_metadata(@user.user_key)
      if work.save
        collection.add_members([work.id])
        collection.save
        add_image(attrs['thumbnail_url'].first, work)
        OaiImporter::LOGGER.info("created work with title: #{attrs['title'].try(:first)} and id: #{work.id}")
      else
        OaiImporter::LOGGER.error("Failed to create Work with title: #{attrs['title'].try(:first)} and Identifier: #{attrs['identifier']}, error messages: #{work.try(:errors).try(:messages)}")
      end
      work
    end

    def add_image(url, work)
      open(url) do |f|
        uploaded_file = Sufia::UploadedFile.create(file: f, user: @user)
        file_set = FileSet.new
        actor = CurationConcerns::Actors::FileSetActor.new(file_set, @user)
        actor.create_metadata(work, visibility: work.visibility) do |file|
          file.permissions_attributes = work.permissions.map(&:to_hash)
        end
        actor.create_content(uploaded_file.file.file)
        uploaded_file.update(file_set_uri: file_set.uri)
      end
    end

    def clean_attrs(attrs)
      @valid_attrs.each_with_object({}) do |attr_name, hash|
        hash[attr_name] = attrs[attr_name] if attrs[attr_name].present?
      end
    end
  end

  class OaiCollectionFactory
    attr_accessor :default_collection_name
    def initialize(user, default_collection_name)
      @user = user
      @default_collection_name = default_collection_name
      @default_collection = Collection.where(title: @default_collection_name).first
      @valid_attrs = Collection.new.attributes.keys
    end

    def build(attrs)
      existing_collection = get_collection(attrs['title'])
      if existing_collection.present?
        existing_collection
      else
        collection = Collection.new
        clean_attrs(attrs).each do |key, value|
          collection.send("#{key}=", value)
        end
        collection.apply_depositor_metadata(@user.user_key)
        collection.save
        OaiImporter::LOGGER.info("Created collection with title: #{attrs['title'].try(:first)} and id: #{collection.id}")
        collection
      end
    end

    def get_collection(title)
      return @default_collection if title.blank?
      Collection.where(title: title).first
    end

    def clean_attrs(attrs)
      @valid_attrs.each_with_object({}) do |attr_name, hash|
        hash[attr_name] = attrs[attr_name] if attrs[attr_name].present?
      end
    end
  end
end
