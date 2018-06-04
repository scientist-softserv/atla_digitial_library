class AddErrorsToHarvetRuns < ActiveRecord::Migration
  def change
    add_column :harvest_runs, :deleted, :integer, default: 0
    add_column :harvest_runs, :failures, :integer, default: 0
  end
end
