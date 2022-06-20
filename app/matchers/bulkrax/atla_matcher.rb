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
      string.slice(0, 1).capitalize + string.slice(1..-1) if string.present?
    end

    # override - clean up special characters
    def parse_remote_files(src)
      src.gsub!("\"", '%22')
      src.gsub!(" ", '%20')
      src.gsub!("'", '%27')
      { url: src.strip } if src.present?
    end

    # Override from Bulkrax v3.0.0.beta7
    # Takes in a string of values and removes any periods
    # creates an array of those values splitting on an empty space
    # does not use 'and' as a language -- oddly enough it's on the language list
    # and adds each languages name into our new array of languages
    def parse_language(src)
      string = src.chomp('.')
      arr_values = string.strip.downcase.split(' ')
      arr_languages = []
      if arr_values.present?
        arr_values.each do |value|
          value = value.chomp(',').strip
          unless value == 'and'
            l = ::LanguageList::LanguageInfo.find(value)
            arr_languages << l.name if l.present?
          end
        end
      end
      arr_languages
    end
  end
end
