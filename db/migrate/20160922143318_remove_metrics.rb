class RemoveMetrics < ActiveRecord::Migration
  def up
    drop_table :metrics
  end
end
