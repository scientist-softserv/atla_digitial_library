module Bulkrax
  class OaiOmekaEntry < OaiDcEntry

    # override to swap out the thumbnail_url
    def build_metadata
      self.parsed_metadata = {}
      self.parsed_metadata[Bulkrax.system_identifier_field] ||= [record.header.identifier]

      record.metadata.children.each do |child|
        child.children.each do |node|
          add_metadata(node.name, node.content)
        end
      end

      identifiers = parsed_metadata['identifier']
      # remove all image urls
      self.parsed_metadata['identifier'] = identifiers.reject { |id| id =~ %r{http(s{0,1})://[s3.amazonaws.com]+\S+.jpg\S+$} } unless identifiers.blank?
      # use first image url as thumbnail in identifiers matching the given pattern
      self.parsed_metadata['remote_files'] = [identifiers.map { |id| { url: id } if id =~ %r{http(s{0,1})://[s3.amazonaws.com]+\S+.jpg\S+$} }.compact.first] unless identifiers.blank?
      self.parsed_metadata['contributing_institution'] = [contributing_institution]
      
      add_visibility
      add_rights_statement
      add_collections

      self.parsed_metadata
    end
  end
end
