module Bulkrax
  class AtlaMatcher < ApplicationMatcher
    def parse_types(src)
      Hyrax::ResourceTypesService.label_from_alt(src.to_s.strip)
    end

    def parse_format_digital(src)
      Hyrax::FormatsService.label_from_alt(src.to_s.strip)
    end

    # override - retain capitalization in existing string, strip spaces and period
    #  then capitalize first letter
    def parse_subject(src)
      string = src.to_s.strip.chomp('.')
      if string.present?
        string.slice(0,1).capitalize + string.slice(1..-1)
      end
    end

    # override - clean up special characters
    def parse_remote_files(src)
      src.gsub!("\"", '%22')
      src.gsub!(" " '%20')
      src.gsub!("'", '%27')
      { url: src.strip } if src.present?
    end
  end
end
