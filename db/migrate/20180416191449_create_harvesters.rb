class CreateHarvesters < ActiveRecord::Migration
  def change
    create_table :harvesters do |t|
      t.string :name
      t.string :admin_set_id, index: true
      t.integer :user_id, index: true
      t.string :external_set_id, index: true
      t.string :base_url
      t.string :institution_name
      t.string :frequency
      t.integer :limit
      t.string :importer
      t.string :right_statement
      t.string :thumbnail_url
      t.integer :total_records
      t.timestamp :last_harvested_at

      t.timestamps null: false
    end
  end
end
