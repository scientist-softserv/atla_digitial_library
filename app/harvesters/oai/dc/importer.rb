require 'oai'
require 'libxml'

module OAI::DC
  class Importer
    attr_accessor :url, :thumbnail_url, :user, :admin_set_id, :rights, :institution, :total, :client, :collection_name

    def initialize(url, thumbnail_url, rights, institution, user, admin_set_id, collection_name, opts = {})
      @url = url
      @thumbnail_url = thumbnail_url
      @rights = rights
      @institution = institution
      @user = user
      @admin_set_id = admin_set_id
      @collection_name = collection_name
      @headers = { from: user.email }

      @work_factory = OAI::DC::WorkFactory.new(admin_set_id, user)

      @client = OAI::Client.new(@url, headers: @headers, parser: 'libxml', metadata_prefix: 'oai_dc')
    end

    def list_identifiers(opts = {})
      @list_identifiers ||= @client.list_identifiers(opts)
    end

    def list_records(opts = {})
      @list_records ||= @client.list_records(opts)
    end

    def list_sets
      @client.list_sets
    end

    def total
      @total ||= list_identifiers.doc.find(".//resumptionToken").to_a.first.attributes["completeListSize"].to_i
    end

    def get_record(identifier, opts = {})
      process_record @client.get_record({identifier: identifier})
    end

    def process_record(record)
      parsed_record = OAI::DC::RecordParser.new(record,
                                                @rights,
                                                @institution,
                                                @thumbnail_url,
                                                collection_name == "all")
      all_attrs = parsed_record.all_attrs
      unless collection_name == "all"
        all_attrs['collection'] ||= []
        all_attrs['collection'] << collection_name
      end
      @work_factory.build(all_attrs)
    end
  end
end
