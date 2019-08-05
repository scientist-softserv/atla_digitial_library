module Bulkrax
  class OaiIaEntry < OaiDcEntry

    # use same matchers as OaiDcEntry (inherit from OaiDcEntry), override date to use parser
    matcher 'date', from: ['date'], parsed: true

    def build_metadata
      self.parsed_metadata = {}
      self.parsed_metadata[Bulkrax.system_identifier_field] ||= [record.header.identifier]

      record.metadata.children.each do |child|
        child.children.each do |node|
          add_metadata(node.name, node.content)
        end
      end
      add_metadata('thumbnail_url', thumbnail_url)

      self.parsed_metadata['contributing_institution'] = [contributing_institution]
      self.parsed_metadata['remote_manifest_url'] ||= build_manifest

      add_visibility
      add_rights_statement
      add_collections

      # @todo remove this when field_mapping is in place
      self.parsed_metadata['contributor'] = nil

      return self.parsed_metadata
    end

    def build_manifest
      url = "https://iiif.archivelab.org/iiif/#{record.header.identifier.split(':').last}/manifest.json"
      return [url] if manifest_available?(url)
    end

    def manifest_available?(url)
      response = Faraday.get url
      if response.status == 200
        true
      else
        false
      end
    end
  end
end
