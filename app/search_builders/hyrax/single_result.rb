# Override file from Hyrax 2.3.3
# Overrides are marked with an "OVERRIDE" comment
module Hyrax
  module SingleResult
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain += [:find_one]
    end

    # OVERRIDE METHOD
    # Tell Solr to search by :slug if it can't find the document by :id
    def find_one(solr_parameters)
      solr_parameters[:fq] << "({!raw f=id}#{blacklight_params.fetch(:id)} OR
                              {!raw f=slug_sim}#{blacklight_params.fetch(:id)})"
    end
  end
end
