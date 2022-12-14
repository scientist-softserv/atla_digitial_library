module Bulkrax
  class CdriCollectionEntry < Entry
    def initialize(attrs = {})
      super(attrs)
      self.identifier ||= raw_metadata_xml['CollectionNameCode'].to_s if raw_metadata.present?
    end

    def self.get_identifier(raw_metadata)
      new(raw_metadata: raw_metadata).identifier
    end

    def factory_class
      Collection
    end

    def raw_metadata_xml
      @raw_metadata_xml ||= Nokogiri::XML.fragment(raw_metadata).elements.first
    end

    def build_metadata
      self.parsed_metadata = {}
      raw_metadata_xml.each_with_object({}) do |(key, value), _hash|
        clean_key = key.gsub(/collection/i, '').gsub(/\d+/, '').underscore
        next if clean_key == 'id'
        val = value.respond_to?(:value) ? value.value : value
        add_metadata(clean_key, val)
      end

      # remove any unspported attributes
      object = factory_class.new
      self.parsed_metadata = parsed_metadata.select do |key, _value|
        object.respond_to?(key.to_sym)
      end

      parsed_metadata['visibility'] = 'open'
      parsed_metadata['collection_type_gid'] = Hyrax::CollectionType.find_or_create_default_collection_type.gid
      parsed_metadata['identifier'] = [self.identifier]
      parsed_metadata
    end
  end
end
