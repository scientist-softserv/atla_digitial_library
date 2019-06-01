Bulkrax.setup do |config|
  config.parsers += [
    { name: "OAI - Princeton Theological Commons", class_name: "Bulkrax::OaiPtcParser", partial: 'oai_fields'},
    {name: "CDRI Xml File", class_name: "Bulkrax::CdriParser", partial: 'cdri_fields'}
  ]
end

