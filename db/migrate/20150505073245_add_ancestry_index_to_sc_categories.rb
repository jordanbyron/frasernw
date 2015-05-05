class AddAncestryIndexToScCategories < ActiveRecord::Migration
  def up
    add_index :sc_categories, :ancestry
  end

  def down
    remove_index :sc_categories, :ancestry
  end
end
