module OAI::PTC
  class RecordParser < OAI::Base::RecordParser
    matcher 'contributor', split: true
    matcher 'creator', split: true
    matcher 'date', from: ['date'], split: true
    matcher 'description'
    matcher 'format_digital', from: ['format_digital', 'format'], parsed: true
    matcher 'identifier', from: ['identifier'], if: ->(parser, content) { content.match(/http(s{0,1}):\/\//) }
    matcher 'language', parsed: true, split: true
    matcher 'place', from: ['coverage']
    matcher 'publisher', split: /\s*[;]\s*/
    matcher 'relation'
    matcher 'subject', split: true
    matcher 'title'
    matcher 'types', from: ['types', 'type'], split: true
  end
end
