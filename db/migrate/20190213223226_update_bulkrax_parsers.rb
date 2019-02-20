class UpdateBulkraxParsers < ActiveRecord::Migration[5.1]
  def change
    Bulkrax::Importer.find_each do |i|
      i.parser_klass = i.parser_klass.gsub("::Parsers", '')
      i.save
    end
  end
end
