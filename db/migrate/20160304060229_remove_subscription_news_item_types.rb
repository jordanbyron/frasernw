class RemoveSubscriptionNewsItemTypes < ActiveRecord::Migration
  def up
    drop_table :subscription_news_item_types
  end

  def down
    create_table :subscription_news_item_types do |t|
      t.references :subscription
      t.integer :news_item_type

      t.timestamps
    end
    add_index :subscription_news_item_types, :subscription_id
  end
end
