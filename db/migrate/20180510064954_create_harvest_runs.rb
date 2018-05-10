class CreateHarvestRuns < ActiveRecord::Migration
  def change
    create_table :harvest_runs do |t|
      t.references :harvester, index: true, foreign_key: true
      t.integer :total, default: 0
      t.integer :enqueued, default: 0
      t.integer :processed, default: 0

      t.timestamps null: false
    end
  end
end
