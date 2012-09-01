class AddOrderToScCategories < ActiveRecord::Migration
  def change
    add_column :sc_categories, :sort_order, :integer, :default => 10
  end
end
