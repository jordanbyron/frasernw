class AddDivisionsToUsers < ActiveRecord::Migration
  def change
    create_table :division_users do |t|
      t.integer :division_id
      t.integer :user_id

      t.timestamps
    end
  end
end
