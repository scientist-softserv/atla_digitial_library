## adding additional fields here
# This class gets called by ActiveFedora::IndexingService#olrize_rdf_assertions
class AtlaCollectionMetadataIndexer < BasicMetadataIndexer
  self.stored_and_facetable_fields = %i[resource_type creator contributor keyword publisher subject language based_near contributing_institution date slug]
end
