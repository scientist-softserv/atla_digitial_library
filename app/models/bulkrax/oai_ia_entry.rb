module Bulkrax
  class OaiIaEntry < OaiDcEntry
    include Bulkrax::Concerns::HasMatchers

    def build_metadata
      self.parsed_metadata = {}

      record.metadata.children.each do |child|
        child.children.each do |node|
          add_metadata(node.name, node.content)
        end
      end
      add_metadata('thumbnail_url', thumbnail_url)

      self.parsed_metadata['contributing_institution'] = [contributing_institution]
      self.parsed_metadata[Bulkrax.system_identifier_field] ||= [record.header.identifier]
      self.parsed_metadata['remote_manifest_url'] ||= ["https://iiif.archivelab.org/iiif/#{record.header.identifier.split(':').last}/manifest.json"]

      add_visibility
      add_rights_statement
      add_collections

      # @todo remove this when field_mapping is in place
      self.parsed_metadata['contributor'] = nil
      self.parsed_metadata['format'] = nil

      return self.parsed_metadata
    end
  end
end
