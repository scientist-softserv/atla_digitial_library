module OAI::ModsDC
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

    def all_attrs
      merge_attrs(header, metadata)
    end

    def header
      { 'thumbnail_url' => ["#{@thumbnail_url}?cover=#{record.header.identifier.split(':').last}&size=L"] }
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
