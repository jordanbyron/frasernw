class CreateSubscriptionDivisions < ActiveRecord::Migration
  def change
    create_table :subscription_divisions do |t|
      t.references :division
      t.references :subscription

      t.timestamps
    end
    add_index :subscription_divisions, :division_id
    add_index :subscription_divisions, :subscription_id
  end
end
