class CreateHospitalAddresses < ActiveRecord::Migration
  def change
    create_table :hospital_addresses do |t|
      t.integer :hospital_id
      t.integer :address_id
      
      t.timestamps
    end
  end
end
