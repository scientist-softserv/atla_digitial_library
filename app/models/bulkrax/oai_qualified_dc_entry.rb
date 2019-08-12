module Bulkrax
  class OaiQualifiedDcEntry < OaiEntry
    def self.matcher_class
      Bulkrax::AtlaOaiMatcher
    end
  end
end
