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
      if override_rights_statement || self.parsed_metadata['rights_statement'].blank?
        self.parsed_metadata['rights_statement'] = [rights_statement]
      end
      self.parsed_metadata['visibility'] = 'open'
      self.parsed_metadata['source'] ||= [record.header.identifier]
      self.parsed_metadata['remote_manifest_url'] ||= ["https://iiif.archivelab.org/iiif/#{record.header.identifier.split(':').last}/manifest.json"]


      # @todo remove this when field_mapping is in place
      self.parsed_metadata['contributor'] = nil
      self.parsed_metadata['format'] = nil

      if collection.present?
        self.parsed_metadata['collections'] ||= []
        self.parsed_metadata['collections'] << {id: self.collection.id}
      end

      return self.parsed_metadata
    end
  end
end
