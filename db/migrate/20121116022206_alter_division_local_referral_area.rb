class AlterDivisionLocalReferralArea < ActiveRecord::Migration
  def change

    drop_table :division_specializations
    drop_table :division_specialization_cities

    create_table :division_referral_cities do |t|
      t.integer :division_id
      t.integer :city_id

      t.timestamps
    end

    create_table :division_referral_city_specializations do |t|
      t.integer :division_referral_city_id
      t.integer :specialization_id

      t.timestamps
    end

  end
end
