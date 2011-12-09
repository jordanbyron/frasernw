class AddHospitalToAddress < ActiveRecord::Migration
  def change
    remove_column :clinic_addresses, :hospital_id
    add_column :addresses, :hospital_id, :integer
  end
end
