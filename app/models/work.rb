class Work < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = WorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  include ::Hyrax::BasicMetadata

  apply_schema Schemas::WorkMetadata, Schemas::GeneratedResourceSchemaStrategy.new

  alias_attribute :rights, :license

  def ancestor_collections
    return @ancestor_collections if @ancestor_collections.present?
    @ancestor_collections = []
    self.member_of_collections.each do |c|
      @ancestor_collections += c.member_of_collections
      @ancestor_collections << c
    end
    return @ancestor_collections
  end

  def ancestor_collection_ids
    ancestor_collections.map &:id
  end
end
