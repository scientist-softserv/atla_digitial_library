module Bulkrax
  class CdriParser < ApplicationParser
    attr_accessor :data, :running_count
    def self.parser_fields
      {
        xml_path: :string,
        upload_path: :string,
        rights_statements: :string,
      }
    end

    def initialize(importer)
      @running_count = 0
      super
    end

    def data
      @data ||= File.open(importer.parser_fields['xml_path']) { |f| Nokogiri::XML(f).remove_namespaces! }
    end

    def run
      create_collections_with_works
    end

    def running_count
      @running_count ||= 0
    end

    def create_collections_with_works
      data.css('Collections').each do |collection_xml|
        collection_identifier = CdriCollectionEntry.get_identifier(collection_xml)
        collection_entry = CdriCollectionEntry.where(importer: self.importer, identifier: collection_identifier).first_or_initialize
        collection_entry.raw_metadata = collection_xml
        collection = collection_entry.build
        collection_entry.save
        create_works(collection_xml, collection)
        if limit && running_count >= limit
          break
        end
      end
    end

    def create_works(collection_xml, collection)
      collection_xml.css('Components').select do |component_xml|
        ImporterRun.find(current_importer_run.id).increment!(:enqueued_records)
        if only_updates && Work.where(identifier: [component_xml["ComponentID"].to_s]).count > 0
          ImporterRun.find(current_importer_run.id).increment!(:processed_records)
          Rails.logger.info "skipped #{component_xml["ComponentID"]}"
          next
        end
        begin
          work_identifier = CdriWorkEntry.get_identifier(component_xml)
          new_entry = entry_class.where(importer: self.importer, identifier: work_identifier).first_or_initialize do |e|
            e.collection_id = collection.id
          end
          new_entry.raw_metadata = component_xml
          new_entry.save!
          ImportWorkJob.perform_later(new_entry.id, importer.current_importer_run.id)
          ImporterRun.find(current_importer_run.id).increment!(:processed_records)
        rescue => e
          Rails.logger.error "Import ERROR: #{component_xml["ComponentID"].to_s} - Message: #{e.message}"
          ImporterRun.find(current_importer_run.id).increment!(:failed_records)
        end

        self.running_count += 1
        if limit && running_count >= limit
          break
        end
        false
      end
    end

    def entry_class
      CdriWorkEntry
    end

    def mapping_class
      CdriMapping
    end

    # the set of fields available in the import data
    def import_fields
      ['contributor', 'coverage', 'creator', 'date', 'description', 'format', 'identifier', 'language', 'pub_place', 'publisher', 'pub_date', 'relation', 'rights', 'source', 'subject', 'title', 'type']
    end

    def total
      @total ||= data.css('Components').count
    rescue
      @total = 0
    end

  end
end
