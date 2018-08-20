require 'oai'
require 'libxml'

module OAI::Base
  class Importer
    attr_accessor :url, :headers, :thumbnail_url, :user, :admin_set_id, :rights, :institution, :total, :client, :collection_name, :metadata_prefix

    def initialize(url, thumbnail_url, rights, institution, user, admin_set_id, collection_name, metadata_prefix, opts = {})
      @url = url
      @thumbnail_url = thumbnail_url
      @rights = rights
      @institution = institution
      @user = user
      @admin_set_id = admin_set_id
      @collection_name = collection_name
      @metadata_prefix = metadata_prefix
      @headers = { from: user.email }
      @use_harvester_name = opts[:use_harvester_name] if opts[:use_harvester_name].present?
    end

    def work_factory
      @work_factory ||= OAI::Base::WorkFactory.new(admin_set_id, user)
    end

    def client
      @client ||= OAI::Client.new(url, headers: headers, parser: 'libxml', metadata_prefix: @metadata_prefix)
    end

    def record_parser_class
      OAI::Base::RecordParser
    end

    def list_identifiers(opts = {})
      @list_identifiers ||= client.list_identifiers(opts)
    end

    def list_records(opts = {})
      @list_records ||= client.list_records(opts)
    end

    def list_sets
      client.list_sets
    end

    def total
      @total ||= list_identifiers.doc.find(".//resumptionToken").to_a.first.attributes["completeListSize"].to_i
    rescue
      @total = 0
    end

    def get_record(identifier, opts = {})
      process_record client.get_record({identifier: identifier})
    end

    def process_record(record)
      parsed_record = record_parser_class.new(
        record,
        rights,
        institution,
        thumbnail_url,
        collection_name == "all"
      )

      all_attrs = parsed_record.all_attrs

      if @use_harvester_name
        all_attrs['collection'] ||= []
        all_attrs['collection'] << collection_name
      else
        unless collection_name == "all"
          all_attrs['collection'] ||= []
          all_attrs['collection'] << collection_name
        end
      end

      work_factory.build(all_attrs)
    end
  end
end
