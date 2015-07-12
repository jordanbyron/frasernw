class CreateClinicAddresses < ActiveRecord::Migration
  def change
    create_table :clinic_addresses do |t|
      t.integer :clinic_id
      t.integer :address_id
      t.integer :hospital_id

      t.timestamps
    end
  end
end
