# Generated via
#  `rails generate hyrax:work Work`
class WorkIndexer < Hyrax::WorkIndexer
  # Override the default mete data for the Atla superset
  def rdf_service
    AtlaWorkMetadataIndexer
  end

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata
end
