module Bulkrax
  class CdriWorkEntry < Entry

    def initialize(attrs={})
      super(attrs)
      self.identifier ||= raw_metadata_xml['ComponentID'].to_s if raw_metadata.present?
    end

    def self.get_identifier(raw_metadata)
      self.new(raw_metadata: raw_metadata).identifier
    end

    def collection
      @collection ||= Collection.find(self.collection_ids.first) if self.collection_ids.present?
    end

    def files_path
      File.join(parser.parser_fields['upload_path'], collection.name_code.first)
    end

    def factory
      @factory ||= Bulkrax::ApplicationFactory.for(factory_class.to_s).new(self.parsed_metadata, identifier, files_path, [], user)
    end

    def factory_class
      Work
    end

    def raw_metadata_xml
      @raw_metadata_xml ||= Nokogiri::XML.fragment(raw_metadata).elements.first
    end

    def build_metadata
      self.parsed_metadata = {}
      raw_metadata_xml.each_with_object({}) do |(key, value), hash|
        clean_key = key.gsub(/component/i, '').gsub(/\d+/, '').underscore.downcase
        next if clean_key == 'id'
        val = value.respond_to?(:value) ? value.value : value
        add_metadata(clean_key, val)
      end

      # remove any unsupported attributes
      object = factory_class.new
      self.parsed_metadata = self.parsed_metadata.select do |key, value|
        object.respond_to?(key.to_sym)
      end

      add_visibility
      add_rights_statement
      add_collections

      self.parsed_metadata['file'] = [raw_metadata_xml["ComponentFileName"].downcase] if raw_metadata_xml["ComponentFileName"].present?
      self.parsed_metadata[Bulkrax.system_identifier_field] ||= [self.identifier]
      self.parsed_metadata['has_manifest'] = "1"
      return self.parsed_metadata
    end
  end
end
