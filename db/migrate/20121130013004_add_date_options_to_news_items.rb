class AddDateOptionsToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :show_start_date, :boolean, :default => true
    add_column :news_items, :show_end_date, :boolean, :default => true
  end
end
