class AddUrgentReferralDetails < ActiveRecord::Migration
  def change
    add_column :specialists, :urgent_details, :text
    add_column :clinics, :urgent_details, :text
  end
end
