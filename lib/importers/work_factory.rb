module Atla
  class WorkFactory
    attr_reader :user

    def initialize(attrs, user)
      @attrs = attrs
      @user = user
    end

    def build
      work = Work.new
      clean_attrs.each do |(method, value)|
        work.send((method + '=').to_sym, value)
      end
      work.apply_depositor_metadata(user.user_key)
      work
    end

    private

    def clean_attrs
      @clean_attrs = @attrs.each_with_object({}) do |(key, value), hash|
        clean_key = key.gsub(/component/i, '').gsub(/\d+/, '').underscore
        if Work.new.respond_to?(clean_key.to_sym) && clean_key != 'id'
          hash[clean_key] ||= []
          hash[clean_key] << value.value
        end
      end
    end
  end
end
