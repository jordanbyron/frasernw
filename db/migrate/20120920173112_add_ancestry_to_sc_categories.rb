class AddAncestryToScCategories < ActiveRecord::Migration
  def change
    add_column :sc_categories, :ancestry, :string
  end
end
