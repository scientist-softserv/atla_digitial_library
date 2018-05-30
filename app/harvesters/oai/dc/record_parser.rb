module OAI::DC
  class RecordParser < OAI::Base::RecordParser
    matcher 'collection', from: ['relation'], if: ->(parser, content) { parser.all }
    matcher 'contributor', split: true
    matcher 'creator', split: true
    matcher 'date', from: ['date'], split: true
    matcher 'description'
    matcher 'format_digital', from: ['format_digital', 'format'], parsed: true
    matcher 'language', parsed: true, split: true
    matcher 'original_url', from: ['identifier'], if: ->(parser, content) { content.match(/http(s+):\/\//) }
    matcher 'place', from: ['coverage']
    matcher 'subject', split: true
    matcher 'title', split: true
    matcher 'types', from: ['types', 'type'], split: true

  end
end
