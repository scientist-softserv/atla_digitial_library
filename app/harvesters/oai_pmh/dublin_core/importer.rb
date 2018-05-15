require 'oai'
require 'libxml'

module OAI::DC
  class Importer
    attr_accessor :url, :thumbnail_url, :user, :admin_set_id, :rights, :institution, :total, :client

    def initialize(url, thumbnail_url, rights, institution, user, admin_set_id, opts = {})
      @url = url
      @thumbnail_url = thumbnail_url
      @rights = rights
      @institution = institution
      @user = user
      @admin_set_id = admin_set_id

      @headers = { from: user.email }

      @collection_factory = OAI::DC::CollectionFactory.new(user)
      @work_factory = OAI::DC::WorkFactory.new(admin_set_id, user)
      @work_factory.collection_factory = @collection_factory

      @client = OAI::Client.new(@url, headers: @headers, parser: 'libxml', metadata_prefix: 'oai_dc')
    end

    def list_identifiers(opts = {})
      @list_identifiers ||= @client.list_identifiers(opts)
    end

    def total
      @total ||= list_identifiers.doc.find(".//resumptionToken").to_a.first.attributes["completeListSize"].to_i
    end

    def get_record(identifier, opts = {})
      process_record @client.get_record({identifier: identifier})
    end

    def process_record(record)
      begin
        parsed_record = OAI::DC::RecordParser.new(record, @rights, @institution, @thumbnail_url)

        @work_factory.build(parsed_record.all_attrs)
      rescue => e
        Raven.capture_exception(e)
      end
    end
  end
end
