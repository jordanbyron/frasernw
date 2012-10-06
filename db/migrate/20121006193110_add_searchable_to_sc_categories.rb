class AddSearchableToScCategories < ActiveRecord::Migration
  def change
    add_column :sc_categories, :searchable, :boolean, :default => true
  end
end
