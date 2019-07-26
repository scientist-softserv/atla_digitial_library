module Bulkrax
  class OaiDcEntry < OaiEntry

    def self.matcher_class
      Bulkrax::AtlaOaiMatcher
    end

  end
end
