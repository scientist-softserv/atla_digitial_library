# Generated via
#  `rails generate curation_concerns:work Work`
class Work < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include Sufia::WorkBehavior
  self.human_readable_type = 'Work'
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # property :title, predicate: ::RDF::Vocab::DC.title { |i| i.as :stored_searchable }
  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative do |i|
    i.as :stored_searchable, :facetable
  end
  # property :collection_name, predicate: ::RDF::Vocab::DC.isPartOf { |i| i.as :stored_searchable }
  property :contributing_instituion, predicate: ::RDF::Vocab::DC.contributor do |i|
    i.as :stored_searchable, :facetable
  end
  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable, :facetable
  end
  property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
    index.as :stored_searchable, :facetable
  end
  property :date, predicate: ::RDF::Vocab::DC11.date do |i|
    i.as :stored_searchable, :facetable
  end
  property :description, predicate: ::RDF::Vocab::DC11.description do |index|
    index.type :text
    index.as :stored_searchable
  end
  property :extent, predicate: ::RDF::Vocab::DC.extent do |i|
    i.as :stored_searchable, :facetable
  end
  property :format_original, predicate: ::RDF::Vocab::DC.medium do |i|
    i.as :stored_searchable, :facetable
  end
  property :format_digital, predicate: ::RDF::Vocab::DC11.format do |i|
    i.as :stored_searchable, :facetable
  end
  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :stored_searchable, :facetable
  end
  property :language, predicate: ::RDF::Vocab::DC11.language do |index|
    index.as :stored_searchable, :facetable
  end
  property :place, predicate: ::RDF::Vocab::DC.coverage do |i|
    i.as :stored_searchable, :facetable
  end
  property :publisher, predicate: ::RDF::Vocab::DC11.publisher do |index|
    index.as :stored_searchable, :facetable
  end
  property :relation, predicate: ::RDF::Vocab::DC11.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end
  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |i|
    i.as :stored_searchable, :facetable
  end
  property :subject, predicate: ::RDF::Vocab::DC11.subject do |index|
    index.as :stored_searchable, :facetable
  end
  property :thumbnail_url, predicate: ::RDF::Vocab::DC.hasVersion do |i|
    i.as :stored_searchable
  end
  property :time_period, predicate: ::RDF::Vocab::DC.temporal do |i|
    i.as :stored_searchable, :facetable
  end
  property :types, predicate: ::RDF::Vocab::DC11.type do |i|
    i.as :stored_searchable, :facetable
  end

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

  property :original_url, predicate: ::RDF::Vocab::DC.URI do |i|
    i.as :stored_searchable
  end

  # required for file based import
  # property :file_name, predicate: ::RDF::Vocab::DC.identifier { |index| index.as :stored_searchable }
  # property :old_id, predicate: ::RDF::Vocab::DC.identifier
  # required for file based import

  # property :rights_license, predicate: ::RDF::Vocab::DC.license { |i| i.as :stored_searchable }
  # property :system, predicate: ::RDF::Vocab::DC.LinguisticSystem { |index| index.as :stored_searchable }
  # property :pub_place, predicate: ::RDF::Vocab::DC.Location { |index| index.as :stored_searchable }
  # property :data_note, predicate: ::RDF::Vocab::DC.format { |index| index.as :stored_searchable }
  # property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
  # property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
  # property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false do |index| index.as :symbol end
  # property :part_of, predicate: ::RDF::Vocab::DC.isPartOf
  # property :keyword, predicate: ::RDF::Vocab::DC11.relation { |index| index.as :stored_searchable, :facetable }
  # property :rights_statement, predicate: ::RDF::Vocab::EDM.rights do |index| index.as :stored_searchable end
  # property :date_created, predicate: ::RDF::Vocab::DC.created do |index| index.as :stored_searchable end
  # property :based_near, predicate: ::RDF::Vocab::FOAF.based_near do |index| index.as :stored_searchable, :facetable end
  # property :related_url, predicate: ::RDF::RDFS.seeAlso do |index| index.as :stored_searchable end
  # property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index| index.as :stored_searchable end
  # property :source, predicate: ::RDF::Vocab::DC.source do |index| index.as :stored_searchable end
end
