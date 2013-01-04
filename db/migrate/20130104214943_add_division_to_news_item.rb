class AddDivisionToNewsItem < ActiveRecord::Migration
  def change
    add_column :news_items, :division_id, :integer
    
    NewsItem.all.each do |news_item|
      news_item.division = Division.first
      news_item.save
    end
  end
end
