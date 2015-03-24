class RemoveUnusedFieldsFromSubscription < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :item_type
    remove_column :subscriptions, :news_item
    remove_column :subscriptions, :content_item

  end

  def down
    add_column :subscriptions, :item_type, :string
    add_column :subscriptions, :news_item, :string
    add_column :subscriptions, :content_item, :boolean
  end
end
