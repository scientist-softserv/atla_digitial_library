# frozen_string_literal: true

class Collection < ActiveFedora::Base
  before_save :set_slug

  include ::Hyrax::CollectionBehavior

  def to_param
    self.slug || self.id
  end

  def self.find(id_or_slug)
    results = where(slug: id_or_slug).first
    results = ActiveFedora::Base.find(id_or_slug) unless results.present?

    results
  end

  def set_slug
    self.slug = title.first if slug.blank?
    self.slug = slug.parameterize
  end

  ##
  # Override method that does not currently scale to large collections,
  # disabling size sorting of collections.
  def bytes
    0
  end

  def reindex_extent
    @reindex_extent ||= Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
  end

  apply_schema Schemas::CollectionMetadata,
               Schemas::GeneratedResourceSchemaStrategy.new

  property :slug, predicate: ::RDF::Vocab::DC.alternative, multiple: false do |index|
    index.as :stored_searchable
  end

  # You can replace these metadata if they're not suitable
  # moved to bottom of class to avoid issues with "slug property"
  include Hyrax::BasicMetadata
  self.indexer = CollectionIndexer
end
