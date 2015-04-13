class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
     t.references :user
     t.string :classification
     t.boolean :content_item
     t.boolean :news_item
     t.string :item_type
     t.string :news_type
     t.string :interval

     t.timestamps
    end
    add_index :subscriptions, :user_id
  end
end
