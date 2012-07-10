class AddScItemType < ActiveRecord::Migration
  def change
    add_column :sc_items, :type_mask, :integer
    rename_column :sc_items, :name, :title
    add_column :sc_items, :url, :string
    add_column :sc_items, :markdown_content, :text
  end
end
