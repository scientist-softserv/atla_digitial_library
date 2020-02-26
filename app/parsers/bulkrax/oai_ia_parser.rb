module Bulkrax
  # Parser for the Internet Archive OAI-PMH Endpoint
  class OaiIaParser < OaiDcParser
    
    def entry_class
      OaiIaEntry
    end

    def create_collections
      metadata = {
        visibility: 'open',
        collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
      }

      list_sets.each do |set|
        next unless collection_name == 'all' || collection_name == set.spec

        unique_collection_identifier = importerexporter.unique_collection_identifier(set.spec)

        metadata[:title] = [parser_fields['collection_title'] || set.name]
        metadata[Bulkrax.system_identifier_field] = [unique_collection_identifier]

        new_entry = collection_entry_class.where(importerexporter: self.importerexporter, identifier: unique_collection_identifier, raw_metadata: metadata).first_or_create!
        ImportWorkCollectionJob.perform_later(new_entry.id, importerexporter.current_importer_run.id)
      end
    end

  end
end
