class AddDemoFieldsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :persist_in_demo, :boolean, default: false
  end

  def down
    remove_column :users, :persist_in_demo
  end
end
