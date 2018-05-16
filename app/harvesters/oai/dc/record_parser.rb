require 'language_list'
require 'erb'
require 'ostruct'

module OAI::DC
  class RecordParser
    attr_accessor :record, :rights, :institution, :thumbnail_url

    def initialize(record, rights, institution, thumbnail_url)
      @record = record.record
      @rights = rights
      @institution = institution
      @thumbnail_url = thumbnail_url
    end

    def metadata
      return @metadata if @metadata

      @metadata = record.metadata&.child&.children&.each_with_object({}) do |node, hash|
        case node.name
        when 'language'
          hash['language'] ||= []
          language = parse_language node.content
          hash['language'] << language
        when 'title'
          hash['title'] ||= []
          title = parse_title node.content
          title.each {|t| hash['title'] << t}
        when 'format'
          hash['format_original'] ||= []
          hash['format_original'] << node.content
        when 'coverage'
          hash['place'] ||= []
          hash['place'] << node.content
        when 'relation'
          hash['collection'] ||= []
          hash['collection'] << node.content
        when 'type'
          hash['types'] ||= []
          hash['types'] << node.content
        when 'rights'
          next
        else
          hash[node.name] ||= []
          hash[node.name] << node.content
        end
      end

      if @metadata
        @metadata['contributing_institution'] = [@institution]
        @metadata['rights'] = [@rights]
      end

      @metadata
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
