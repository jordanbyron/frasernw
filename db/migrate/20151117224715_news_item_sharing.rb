class NewsItemSharing < ActiveRecord::Migration
  def up
    create_table :division_display_news_items do |t|
      t.integer :division_id, null: false
      t.integer :news_item_id, null: false

      t.timestamps
    end
    #indices?

    rename_column :news_items, :division_id, :owner_division_id

    NewsItem.all.each do |news_item|
      DivisionDisplayNewsItem.create(
        division_id: news_item.owner_division_id,
        news_item_id: news_item.id
      )
    end
  end

  def down
  end
end
