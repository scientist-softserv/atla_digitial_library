# frozen_string_literal: true

class Collection < ActiveFedora::Base
  before_save :set_slug

  include ::Hyrax::CollectionBehavior
  validates :slug, with: :check_slug

  def to_param
    slug || id
  end

  def self.find(id_or_slug)
    results = where(slug_sim: id_or_slug).first
    results = ActiveFedora::Base.find(id_or_slug) unless results.present?

    results
  end

  def check_slug
    result = if new_record?
               Collection.where(slug_sim: slug).count > 0
             else
               Collection.where(slug_sim: slug).detect { |c| c.id != id }
             end
    errors.add(:slug, 'must be unique') if result
  end

  def set_slug
    return true if slug
    self.slug = title.first
    self.slug = slug.parameterize
    i = 0
    while i < 50
      if Collection.where(slug_sim: slug).count > 0
        self.slug = if i == 0
                      slug + "-1"
                    else
                      slug.gsub("-#{i}", "-#{i + 1}")
                    end
        i += 1
      else
        break
      end
    end
  end

  def works_count
    if is_ancestor_collection?
      collections.reduce(0) { |count, child| count + child.member_work_ids.length }
    else
      member_work_ids.length
    end
  end

  def is_ancestor_collection?
    collection_ids.length > 0
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
