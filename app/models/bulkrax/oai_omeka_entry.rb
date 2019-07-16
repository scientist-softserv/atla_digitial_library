module Bulkrax
  class OaiOmekaEntry < OaiEntry
    include Bulkrax::Concerns::HasMatchers

    def self.matcher_class
      Bulkrax::AtlaOaiMatcher
    end

    matcher 'format_digital', from: ['format'], split: true, parsed: true
    matcher 'types', from: ['type'], split: true, parsed: true
    matcher 'identifier', from: ['identifier'], if: ->(_parser, content) { content.match(%r{http(s{0,1})://}) }
    matcher 'contributor', split: true
    matcher 'creator', split: true
    matcher 'date', from: ['date'], split: true
    matcher 'language', parsed: true, split: true
    matcher 'place', from: ['coverage']
    matcher 'publisher', split: /\s*[;]\s*/
    matcher 'rights_statement', from: ['rights']
    matcher 'subject', split: true

    # override to swap out the thumbnail_url
    def build_metadata
      self.parsed_metadata = {}

      record.metadata.children.each do |child|
        child.children.each do |node|
          add_metadata(node.name, node.content)
        end
      end

      identifiers = parsed_metadata['identifier']
      parsed_metadata['identifier'] = identifiers.reject { |id| id =~ %r{http(s{0,1})://[s3.amazonaws.com]+\S+.jpg\S+$} } unless identifiers.blank?
      parsed_metadata['thumbnail_url'] = [identifiers.select { |id| id =~ %r{http(s{0,1})://[s3.amazonaws.com]+\S+.jpg\S+$} }.first] unless identifiers.blank?

      parsed_metadata['contributing_institution'] = [contributing_institution]
      parsed_metadata['rights_statement'] = [rights_statement] if override_rights_statement || parsed_metadata['rights_statement'].blank?
      parsed_metadata['visibility'] = 'open'
      parsed_metadata['source'] ||= [record.header.identifier]

      if collection.present?
        parsed_metadata['collections'] ||= []
        parsed_metadata['collections'] << { id: collection.id }
      end

      parsed_metadata
    end
  end
end
