class MoveHarvesterImporter < ActiveRecord::Migration
  def change
    rename_column :harvesters, :importer, :importer_name
  end
end
