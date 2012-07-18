class AddToolsToScItems < ActiveRecord::Migration
  def change
    add_column :sc_items, :tool, :boolean, :default => false
  end
end
