# frozen_string_literal: true
class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  self.indexer = Hyrax::CollectionWithBasicMetadataIndexer

  ##
  # Override method that does not currently scale to large collections,
  # disabling size sorting of collections.
  def bytes
    0
  end
end
