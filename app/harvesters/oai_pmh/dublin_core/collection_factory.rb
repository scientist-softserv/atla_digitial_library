module OAI::DC
  class CollectionFactory
    attr_accessor :default_collection_name, :collections

    def initialize(user)
      @user = user
      @valid_attrs = Collection.new.attributes.keys
    end

    def build(attrs)
      return if attrs['title'].blank?

      existing_collection = get_collection(attrs['title'])

      if existing_collection.present?
        Collection.do_index = false
        existing_collection
      else
        Collection.do_index = true
        collection = Collection.new

        clean_attrs(attrs).each do |key, value|
          collection.send("#{key}=", value)
        end

        collection.apply_depositor_metadata(@user.user_key)
        collection.visibility = 'open'
        collection.save

        puts "Created collection with title: #{attrs['title'].try(:first)} and id: #{collection.id}"
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
end
