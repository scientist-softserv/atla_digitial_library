# Generated via
#  `rails generate curation_concerns:work Work`
class Work < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  self.human_readable_type = 'Work'
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :system, predicate: ::RDF::Vocab::DC.LinguisticSystem do |index|
    index.as :stored_searchable
  end

  property :pub_place, predicate: ::RDF::Vocab::DC.Location do |index|
    index.as :stored_searchable
  end

  # required
  property :file_name, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :stored_searchable
  end

  property :data_note, predicate: ::RDF::Vocab::DC.format do |index|
    index.as :stored_searchable
  end

  # required
  property :old_id, predicate: ::RDF::Vocab::DC.identifier

  # property :title, predicate: ::RDF::Vocab::DC.title { |i| i.as :stored_searchable }
  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative { |i| i.as :stored_searchable }
  property :contributing_instituion, predicate: ::RDF::Vocab::DC11.contributor { |i| i.as :stored_searchable }
  property :date, predicate: ::RDF::Vocab::DC11.date { |i| i.as :stored_searchable }
  property :extent, predicate: ::RDF::Vocab::DC.extent { |i| i.as :stored_searchable }
  property :original_format, predicate: ::RDF::Vocab::DC11.format { |i| i.as :stored_searchable }
  property :digital_format, predicate: ::RDF::Vocab::DC11.format { |i| i.as :stored_searchable }
  property :place, predicate: ::RDF::Vocab::DC.Location { |i| i.as :stored_searchable }
  property :relation, predicate: ::RDF::Vocab::DC11.relation { |i| i.as :stored_searchable }
  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder { |i| i.as :stored_searchable }
  property :rights_license, predicate: ::RDF::Vocab::DC.license { |i| i.as :stored_searchable }
  property :thumbnail_url, predicate: ::RDF::Vocab::DC.URI { |i| i.as :stored_searchable }
  property :original_url, predicate: ::RDF::Vocab::DC.URI { |i| i.as :stored_searchable }
  property :time_period, predicate: ::RDF::Vocab::DC.PeriodOfTime { |i| i.as :stored_searchable }
  property :types, predicate: ::RDF::Vocab::DC11.type { |i| i.as :stored_searchable }
end
