Bulkrax.setup do |config|
  config.parsers += [
    { name: 'OAI - Princeton Theological Commons', class_name: 'Bulkrax::OaiPtcParser', partial: 'oai_fields' },
    { name: 'OAI - Omeka', class_name: 'Bulkrax::OaiOmekaParser', partial: 'oai_omeka_fields' },
    { name: 'CDRI Xml File', class_name: 'Bulkrax::CdriParser', partial: 'cdri_fields' }
  ]
end
