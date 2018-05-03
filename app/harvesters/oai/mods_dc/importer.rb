require 'oai'
require 'libxml'

module OAI::ModsDC
  class Importer
    attr_accessor :url, :thumbnail_url, :user, :admin_set_id, :rights, :institution

    def initialize(url, thumbnail_url, rights, institution, user, admin_set_id, opts = {})
      @url = url
      @thumbnail_url = thumbnail_url
      @rights = rights
      @institution = institution
      @user = user
      @admin_set_id = admin_set_id

      @headers = { from: user.email }

      @collection_factory = OAI::ModsDC::CollectionFactory.new(user)
      @work_factory = OAI::ModsDC::WorkFactory.new(admin_set_id, user)
      @work_factory.collection_factory = @collection_factory

      @client = OAI::Client.new(@url, headers: @headers, parser: 'libxml', metadata_prefix: 'mods')
    end

    def list_identifiers(opts = {})
      # TODO: this needs to handle 'limit opt'
      # if opts[:from].present? and !opts[:from].nil?
      #   @client.list_identifiers(opts)
      # else
      #   @client.list_identifiers.full
      # end

      @client.list_identifiers.full
    end

    def get_record(identifier, opts = {})
      process_record @client.get_record({identifier: identifier})
    end

    def process_record(record)
      begin
        parsed_record = OAI::ModsDC::RecordParser.new(record, @rights, @institution, @thumbnail_url)

        @work_factory.build(parsed_record.all_attrs)
      rescue => e
        Raven.capture_exception(e)
      end
    end
  end
end
