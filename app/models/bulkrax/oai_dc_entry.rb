module Bulkrax
  class OaiDcEntry < OaiEntry
    include Bulkrax::Concerns::HasLocalProcessing
    def self.matcher_class
      Bulkrax::AtlaOaiMatcher
    end

  end
end
