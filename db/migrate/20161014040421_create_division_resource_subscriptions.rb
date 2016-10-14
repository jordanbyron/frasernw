class CreateDivisionResourceSubscriptions < ActiveRecord::Migration
  def change
    create_table :division_resource_subscriptions do |t|
      t.references :division
      t.references :specialization

      t.timestamps
    end
  end
end
