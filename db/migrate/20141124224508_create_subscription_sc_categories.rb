class CreateSubscriptionScCategories < ActiveRecord::Migration
  def change
    create_table :subscription_sc_categories do |t|
      t.references :subscription
      t.references :sc_category
      t.timestamps
    end
    add_index :subscription_sc_categories, :subscription_id
    add_index :subscription_sc_categories, :sc_category_id
  end
end
