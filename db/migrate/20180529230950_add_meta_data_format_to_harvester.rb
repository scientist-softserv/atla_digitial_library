class AddMetaDataFormatToHarvester < ActiveRecord::Migration
  def change
    add_column :harvesters, :metadata_prefix, :string
  end
end
