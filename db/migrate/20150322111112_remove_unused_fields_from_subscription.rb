class RemoveUnusedFieldsFromSubscription < ActiveRecord::Migration
  def up
    drop_table :subscription_news_item_types
    remove_column :subscriptions, :item_type
    remove_column :subscriptions, :news_item
    remove_column :subscriptions, :content_item

  end

  def down
    create_table :subscription_news_item_types do |t|
      t.references :subscription
      t.integer :news_item_type

      t.timestamps
    end
    add_index :subscription_news_item_types, :subscription_id

    add_column :subscriptions, :item_type, :string
    add_column :subscriptions, :news_item, :string
    add_column :subscriptions, :content_item, :boolean
  end
end
