class AddMaskFiltersByReferralArea < ActiveRecord::Migration
  def up
    add_column :specializations, :mask_filters_by_referral_area, :boolean, default: false

    family_practice_id = 55
    Specialization.
      find(family_practice_id).
      update_attribute(:mask_filters_by_referral_area, true)
  end

  def down
    remove_column :specializations, :mask_filters_by_referral_area
  end
end
