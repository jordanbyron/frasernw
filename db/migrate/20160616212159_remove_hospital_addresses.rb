class RemoveHospitalAddresses < ActiveRecord::Migration
  def up
    drop_table :hospital_addresses
  end
end
