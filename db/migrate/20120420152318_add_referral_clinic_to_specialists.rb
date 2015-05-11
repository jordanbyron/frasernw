class AddReferralClinicToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :referral_clinic_id, :integer

    add_index :specialists, :referral_clinic_id
  end
end
