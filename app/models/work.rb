class Work < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = WorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  include ::Hyrax::BasicMetadata

  apply_schema Schemas::WorkMetadata, Schemas::GeneratedResourceSchemaStrategy.new
end
