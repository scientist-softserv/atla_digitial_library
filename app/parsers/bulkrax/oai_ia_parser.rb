module Bulkrax
  # Parser for the Internet Archive OAI-PMH Endpoint
  class OaiIaParser < OaiDcParser
    
    def self.parser_fields
      {
        base_url: :string,
        metadata_prefix: :string,
        set: :string,
        institution_name: :string,
        rights_statements: :string,
        override_rights_statement: :boolean,
        thumbnail_url: :string,
        collection_title: :string
      }
    end
    
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

        metadata[:title] = [parser_fields['collection_title'] || set.name]
        metadata[Bulkrax.system_identifier_field] = [set.spec]

        new_entry = collection_entry_class.where(importer: importer, identifier: set.spec, raw_metadata: metadata).first_or_create!
        ImportWorkCollectionJob.perform_later(new_entry.id, importer.current_importer_run.id)
      end
    end

  end
end
