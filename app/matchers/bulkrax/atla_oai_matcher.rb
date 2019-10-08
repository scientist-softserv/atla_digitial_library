module Bulkrax
  class AtlaOaiMatcher < ApplicationMatcher
    def parse_types(src)
      Hyrax::ResourceTypesService.label_from_alt(src.to_s.strip)
    end

    def parse_format_digital(src)
      Hyrax::FormatsService.label_from_alt(src.to_s.strip)
    end

    # Extract year only where year is (for example) 1833-01-01T00:00:00Z
    def parse_date(src)
      if src =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}T00:00:00Z/
        src[0,4] 
      else
        src
      end
    end

    # override - retain capitalization in existing string, strip spaces and period
    #  then capitalize first letter
    def parse_subject(src)
      string = src.to_s.strip.chomp('.')
      if string.present?
        string.slice(0,1).capitalize + string.slice(1..-1)
      end
    end
  end
end
