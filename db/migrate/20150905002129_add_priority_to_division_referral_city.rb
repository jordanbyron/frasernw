class AddPriorityToDivisionReferralCity < ActiveRecord::Migration
  def up
    add_column :division_referral_cities, :priority, :integer, default: City::PRIORITY_SETTINGS
  end

  def down
    remove_column :division_referral_cities, :priority
  end
end
