class AddClinicToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :clinic_id, :integer
  end
end
