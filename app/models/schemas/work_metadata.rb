module Schemas
  class WorkMetadata < ActiveTriples::Schema
    property :alternative_title, predicate: ::RDF::Vocab::DC.alternative
    property :contributing_institution, predicate: ::RDF::Vocab::DC.contributor
    property :date, predicate: ::RDF::Vocab::DC11.date
    property :extent, predicate: ::RDF::Vocab::DC.extent
    property :format_digital, predicate: ::RDF::Vocab::DC11.format
    property :format_original, predicate: ::RDF::Vocab::DC.medium
    property :original_url, predicate: ::RDF::Vocab::DC.URI
    property :place, predicate: ::RDF::Vocab::DC.coverage
    property :relation, predicate: ::RDF::Vocab::DC11.relation
    property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder
    property :time_period, predicate: ::RDF::Vocab::DC.temporal
    property :thumbnail_url, predicate: ::RDF::Vocab::DC.hasVersion
    property :remote_manifest_url, predicate: ::RDF::Vocab::DC.hasFormat
    property :types, predicate: ::RDF::Vocab::DC11.type
  end
end
