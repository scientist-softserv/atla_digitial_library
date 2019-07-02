class FixBulkraxImporterColumn < ActiveRecord::Migration[5.1]
  def change
    if column_exists? :bulkrax_importer_runs, :bulkrax_importer_id
      rename_column :bulkrax_importer_runs, :bulkrax_importer_id, :importer_id
    end
  end
end
