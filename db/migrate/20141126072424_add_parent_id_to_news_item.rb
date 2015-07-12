class AddParentIdToNewsItem < ActiveRecord::Migration
  def change
    add_column :news_items, :parent_id, :integer
  end
end
