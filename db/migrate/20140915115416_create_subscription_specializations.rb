class CreateSubscriptionSpecializations < ActiveRecord::Migration
  def change
    create_table :subscription_specializations do |t|
      t.references :specialization
      t.references :subscription

      t.timestamps
    end
    add_index :subscription_specializations, :specialization_id
    add_index :subscription_specializations, :subscription_id
  end
end
