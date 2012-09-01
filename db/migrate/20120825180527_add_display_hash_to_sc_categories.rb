class AddDisplayHashToScCategories < ActiveRecord::Migration
  def change
    add_column :sc_categories, :display_mask, :integer, :default => 1
    add_column :sc_categories, :show_as_dropdown, :boolean, :default => false
    remove_column :sc_items, :tool
  end
end
