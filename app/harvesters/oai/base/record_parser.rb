require 'language_list'
require 'erb'
require 'ostruct'

module OAI::Base
  class RecordParser
    attr_accessor :record, :rights, :institution, :thumbnail_url

    def initialize(record, rights, institution, thumbnail_url, all = false)
      @record = record.record
      @rights = rights
      @institution = institution
      @thumbnail_url = thumbnail_url
      @all = all
    end

    def metadata
      raise 'Must be implemented in the child class'
    end

    def parse_language(src)
      LanguageList::COMMON_LANGUAGES.each do |lang|
        if src == lang.iso_639_1 or src == lang.iso_639_3
          return lange.name
        end
      end

      src
    end

    def parse_title(title)
      res = []

      title.split(/[:|]/).each do |c| # split by ':' and '|'
        res << c.strip
      end

      res
    end

    def all_attrs
      merge_attrs(header, metadata)
    end

    def header
      context = OpenStruct.new(record: record, identifier: record.header.identifier)

      { 'thumbnail_url' => [ERB.new(@thumbnail_url).result(context.instance_eval { binding })] }
    end

    def merge_attrs(first, second)
      return first if second.blank?

      first = {} if first.blank?

      first.merge(second) do |key, old, new|
        if key =~ /identifier/
          merged_value = old if old.first =~ /^http/
          merged_value = new if new.first =~ /^http/
        else
          merged_value = old + new
        end
        merged_value
      end
    end
  end
end
