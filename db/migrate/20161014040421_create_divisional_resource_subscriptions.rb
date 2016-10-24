class CreateDivisionalResourceSubscriptions < ActiveRecord::Migration
  def change
    create_table :divisional_resource_subscriptions do |t|
      t.references :division
      t.text :specialization_ids, array: true, default: []
      t.boolean :nonspecialized, default: false

      t.timestamps
    end
  end
end
