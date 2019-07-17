module Bulkrax
  # Parser for the Internet Archive OAI-PMH Endpoint
  class OaiIaParser < OaiDcParser
    def entry_class
      OaiIaEntry
    end

    # override to bypass list_sets
    # @todo this method will change when bulkrax #9 is merged
    def create_collections
      attrs = {
        title: [collection_name],
        identifier: [collection_name],
        contributing_institution: [parser_fields['institution_name']],
        visibility: 'open',
        collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
      }
      collection = Collection.where(identifier: [collection_name]).first
      Collection.create!(attrs) if collection.blank?
    end
  end
end
