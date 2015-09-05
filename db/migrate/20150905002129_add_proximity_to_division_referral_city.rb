class AddProximityToDivisionReferralCity < ActiveRecord::Migration
  def up
    add_column :division_referral_cities, :proximity, :integer
  end

  def down
    remove_column :division_referral_cities, :proximity
  end
end
