module Bulkrax
  class AtlaOaiMatcher < AtlaMatcher
    # Extract year only where year is (for example) 1833-01-01T00:00:00Z
    def parse_date(src)
      if /[0-9]{4}-[0-9]{2}-[0-9]{2}T00:00:00Z/.match?(src)
        src[0, 4]
      else
        src
      end
    end
  end
end
