module Atla
  class CollectionFactory
    attr_reader :user

    def initialize(attrs, user)
      @attrs = attrs
      @user = user
    end

    def build
      collection = Collection.new
      clean_attrs.each do |(method, value)|
        collection.send((method + '=').to_sym, value)
      end
      collection.apply_depositor_metadata(user.user_key)
      collection
    end

    private

    def clean_attrs
      @clean_attrs = @attrs.each_with_object({}) do |(key, value), hash|
        clean_key = key.gsub(/collection/i, '').gsub(/\d+/, '').underscore
        if Collection.new.respond_to?(clean_key.to_sym) && clean_key != 'id'
          hash[clean_key] ||= []
          hash[clean_key] << value.value.gsub(/\n|\r|\r\n/, ' ')
        end
      end
    end
  end
end
