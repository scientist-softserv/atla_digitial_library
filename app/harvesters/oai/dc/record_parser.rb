module OAI::DC
  class RecordParser < OAI::Base::RecordParser
    matcher 'contributor', split: true
    matcher 'creator', split: true
    matcher 'date', from: ['date'], split: true
    matcher 'description'
    matcher 'format_digital', from: ['format_digital', 'format'], parsed: true
    matcher 'language', parsed: true, split: true
    matcher 'identifier', from: ['identifier'], if: ->(parser, content) { content.match(/http(s{0,1}):\/\//) }
    matcher 'place', from: ['coverage']
    matcher 'publisher', split: /\s*[;]\s*/
    matcher 'relation', split: true
    matcher 'subject', split: true
    matcher 'title', split: true
    matcher 'types', from: ['types', 'type'], split: true
  end
end
