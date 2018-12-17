# frozen_string_literal: true
module Schemas
  class CollectionMetadata < ActiveTriples::Schema
    property :file_name,   predicate: RDF::Vocab::DC.MediaTypeOrExtent # required
    property :institution, predicate: RDF::Vocab::FOAF.based_near
    property :name_code,   predicate: RDF::Vocab::DC.identifier # required
    property :pub_place,   predicate: RDF::Vocab::DC.Location
  end
end
