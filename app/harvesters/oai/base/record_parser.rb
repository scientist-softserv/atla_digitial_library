require 'language_list'
require 'erb'
require 'ostruct'

module OAI::Base
  class RecordParser
    attr_accessor :record, :rights, :institution, :thumbnail_url, :all

    def initialize(record, rights, institution, thumbnail_url, all = false)
      @record = record.record
      @rights = rights
      @institution = institution
      @thumbnail_url = thumbnail_url
      @all = all
    end

    def self.matcher(name, args={})
      @@matchers ||= {}
      from = args[:from] || [name]
      matcher = Matcher.new(to: name, from: from, parsed: args[:parsed], if: args[:if])
      from.each do |lookup|
        @@matchers[lookup] = matcher
      end
    end

    def self.matchers
      @@matchers
    end

    def metadata
      return @metadata if @metadata

      @metadata = record.metadata&.child&.children&.each_with_object({}) do |node, hash|
        matcher = matchers[node.name]

        # Allow for matchers that only happen if we are on the 'all' set
        if matcher
          result = matcher.result
          if result
            key = matcher.to
            hash[key] ||= []
            hash[key] << result 
          end
        end
      end

      if @metadata
        @metadata['contributing_institution'] = [institution]
        @metadata['rights'] = [rights]
      end

      @metadata
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
