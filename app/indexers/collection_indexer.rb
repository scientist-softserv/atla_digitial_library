# Generated via
#  `rails generate hyrax:work Collection`
class CollectionIndexer < Hyrax::CollectionIndexer
  # Override the default mete data for the ATLA superset
  def rdf_service
    AtlaCollectionMetadataIndexer
  end

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata
end
