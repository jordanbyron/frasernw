class UpdateNewsItemDateDefault < ActiveRecord::Migration
  def up
    change_column :news_items, :show_start_date, :boolean, :default => false
    change_column :news_items, :show_end_date, :boolean, :default => false
  end

  def down
    change_column :news_items, :show_start_date, :boolean, :default => true
    change_column :news_items, :show_end_date, :boolean, :default => true
  end
end
