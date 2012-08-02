class AddShowsOnFrontPageToScCategories < ActiveRecord::Migration
  def change
    add_column :sc_categories, :show_on_front_page, :boolean, :default => true
  end
end
