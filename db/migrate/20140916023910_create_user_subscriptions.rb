class CreateUserSubscriptions < ActiveRecord::Migration
  def change
    create_table :user_subscriptions do |t|
      t.references :user
      t.references :subscription

      t.timestamps
    end
    add_index :user_subscriptions, :user_id
    add_index :user_subscriptions, :subscription_id
  end
end
