class DestroyModerations < ActiveRecord::Migration
  def up
    drop_table :moderations
  end

  def down
  end
end
