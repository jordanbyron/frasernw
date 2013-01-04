class AddTypeToNewsItem < ActiveRecord::Migration
  def change
    add_column :news_items, :type_mask, :integer
    
    NewsItem.all.each do |news_item|
      news_item.type_mask = news_item.breaking? ? NewsItem::TYPE_BREAKING : NewsItem::TYPE_DIVISIONAL
      news_item.save
    end
    
    remove_column :news_items, :breaking
  end
end
