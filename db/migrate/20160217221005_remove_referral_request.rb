class RemoveReferralRequest < ActiveRecord::Migration
  def up
    remove_column :specialists, :referral_request
  end

  def down
  end
end
