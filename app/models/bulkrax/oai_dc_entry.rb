module Bulkrax
  class OaiDcEntry < OaiEntry

    def self.matcher_class
      Bulkrax::AtlaOaiMatcher
    end

    matcher 'contributor', split: /\s*[;]\s*/
    matcher 'creator', split: /\s*[;]\s*/
    matcher 'date', from: ['date'], split: /\s*[;]\s*/
    matcher 'description'
    matcher 'format_digital', from: ['format_digital', 'format'], parsed: true
    matcher 'identifier', from: ['identifier'], if: ->(parser, content) { content.match(/http(s{0,1}):\/\//) }
    matcher 'language', parsed: true, split: /\s*[;]\s*/
    matcher 'place', from: ['coverage']
    matcher 'publisher', split: /\s*[;]\s*/
    # NOTE (dewey4iv): Commented out per Rob. Being removed temporarily for ATLA's use
    # matcher 'relation', split: true
    matcher 'rights_statement', from: ['rights']
    matcher 'subject', split: /\s*[;]\s*/
    matcher 'title'
    matcher 'types', from: ['types', 'type'], split: /\s*[;]\s*/, parsed: true
    matcher 'remote_files', from: ['thumbnail_url'], parsed: true
  end
end
