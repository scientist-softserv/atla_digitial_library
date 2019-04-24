## adding additional fields here
# This class gets called by ActiveFedora::IndexingService#olrize_rdf_assertions
class AtlaWorkMetadataIndexer < Hyrax::BasicMetadataIndexer
  self.stored_and_facetable_fields = %i[resource_type creator contributor keyword publisher subject language based_near contributing_institution date place extent format_original time_period format_digital types rights_holder relation remote_manifest_url has_manifest]
end
