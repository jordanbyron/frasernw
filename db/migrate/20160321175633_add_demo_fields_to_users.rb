class AddDemoFieldsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :clone_to_demo, :boolean, default: false
    add_column :users, :persist_in_demo, :boolean, default: false
  end

  def down
    remove_column :users, :clone_to_demo
    remove_column :users, :persist_in_demo
  end
end
