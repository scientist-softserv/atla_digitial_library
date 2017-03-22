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

  property :file_name, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :stored_searchable
  end

  property :data_note, predicate: ::RDF::Vocab::DC.format do |index|
    index.as :stored_searchable
  end

  property :old_id, predicate: ::RDF::Vocab::DC.identifier
end
