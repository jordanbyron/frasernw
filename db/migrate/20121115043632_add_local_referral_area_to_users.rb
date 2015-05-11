class AddLocalReferralAreaToUsers < ActiveRecord::Migration
  def change
    create_table :user_cities do |t|
      t.integer :user_id
      t.integer :city_id

      t.timestamps
    end

    create_table :user_city_specializations do |t|
      t.integer :user_city_id
      t.integer :specialization_id

      t.timestamps
    end
  end
end
