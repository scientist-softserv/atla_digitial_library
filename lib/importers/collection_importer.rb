require Rails.root.join('lib', 'importers', 'collection_factory')
require Rails.root.join('lib', 'importers', 'work_factory')

module Atla
  class CollectionImporter
    def initialize(path, user_email)
      @path = path
      @user = User.where(email: user_email).first
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
        fedora_collection = new_collection(collection.attributes, @user)
        fedora_collection.save
        create_works(collection, fedora_collection)
      end
    end

    def create_works(collection, fedora_collection)
      works = collection.css('Components').map do |component|
        fedora_work = new_work(component.attributes, @user)
        fedora_work.save
        fedora_work
      end
      fedora_collection.add_members(works.map(&:id))
      fedora_collection.save
    end

    def new_collection(attrs, user)
      CollectionFactory.new(attrs, user).build
    end

    def new_work(attrs, user)
      WorkFactory.new(attrs, user).build
    end
  end
end
