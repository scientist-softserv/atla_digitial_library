class AddTranscriptToImporters < ActiveRecord::Migration[5.1]
  def change
    Bulkrax::Importer.where(parser_klass: "Bulkrax::OaiQualifiedDcParser").find_each do |i|
      i.field_mapping ||= {}
      i.field_mapping['transcript_url'] = {"from"=>["transcript"]}
      i.save
    end
  end
end
