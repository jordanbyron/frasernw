class RemoveReferralRequest < ActiveRecord::Migration
  def up
    remove_column :specialists, :referral_request
  end

  def down
    add_column :specialists, :referral_request, :string
  end
end
