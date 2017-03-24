require Rails.root.join('lib', 'importers', 'collection_factory')
require Rails.root.join('lib', 'importers', 'work_factory')

module Atla
  class CollectionImporter
    def initialize(path, user_email, logger)
      @path = path
      @user = User.where(email: user_email).first
      @logger = logger
    end

    def process
      puts "Processing #{@path}"
      create_collections
    end

    private

    def data
      @data ||= File.open(@path) { |f| Nokogiri::XML(f).remove_namespaces! }
    end

    def create_collections
      data.css('Collections').each do |collection|
        begin
          fedora_collection = new_collection(collection.attributes, @user)
          existing_collection = Collection.where(name_code: fedora_collection.name_code).first
          if existing_collection.present?
            log("collection already exisits, #{existing_collection.inspect}")
          else
            fedora_collection.save
            create_works(collection, fedora_collection)
          end
        rescue Exception => e
          log("#{e}, Failed to save fedora_collection: #{fedora_collection.inspect}")
        end
      end
    end

    def create_works(collection, fedora_collection)
      works = collection.css('Components').map do |component|
        begin
          fedora_work = new_work(component.attributes, @user)
          fedora_work.save
        rescue Exception => e
          log("#{e}, Failed to save fedora_work: #{fedora_work.inspect}")
        end
        fedora_work
      end
      begin
        fedora_collection.add_members(works.map(&:id))
      rescue Exception => e
        log("#{e}, Failed to add works to collection: #{fedora_collection.inspect}")
      end
      fedora_collection.save
    end

    def new_collection(attrs, user)
      CollectionFactory.new(attrs, user).build
    end

    def new_work(attrs, user)
      WorkFactory.new(attrs, user).build
    end

    def log(value)
      puts value
      @logger.error(value)
    end
  end
end
