# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior
  attribute :date, Solr::Date, solr_name('date', :stored_sortable, type: :date)
  attribute :contributing_institution, Solr::Array, solr_name('contributing_institution')
  attribute :place, Solr::Array, solr_name('place')
  attribute :extent, Solr::Array, solr_name('extent')
  attribute :format_original, Solr::Array, solr_name('format_original')
  attribute :alternative_title, Solr::Array, solr_name('alternative_title')
  attribute :time_period, Solr::Array, solr_name('time_period')
  attribute :format_digital, Solr::Array, solr_name('format_digital')
  attribute :types, Solr::Array, solr_name('types')
  attribute :rights_holder, Solr::Array, solr_name('rights_holder')
  attribute :remote_manifest_url, Solr::Array, solr_name('remote_manifest_url')
  attribute :slug, Solr::Array, solr_name('slug')
  attribute :member_of_collections, Solr::Array, "member_of_collections_ssim"
  attribute :has_manifest, Solr::Array, solr_name('has_manifest')
  attribute :ancestor_collection_ids, Solr::Array, solr_name('ancestor_collection_ids')
  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)


  # Do content negotiation for AF models.
  def to_param
    self.slug&.first || self.id
  end

  def date
    self[Solrizer.solr_name('date')]
  end

  use_extension( Hydra::ContentNegotiation )
end
