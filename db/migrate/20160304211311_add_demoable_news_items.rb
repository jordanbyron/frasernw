class AddDemoableNewsItems < ActiveRecord::Migration
  def up
    create_table :demoable_news_items do |t|
      t.integer :news_item_id

      t.timestamps
    end
  end

  def down
    drop_table :demoable_news_items
  end
end
