class CreateHospitalAddresses < ActiveRecord::Migration
  def change
    create_table :hospital_addresses do |t|
      t.integer :hospital_id
      t.integer :address_id
      t.timestamps
    end
    Hospital.all.each { 
      |hospital| hospital.addresses.create(:address1 => hospital.address1,
                                       :address2 => hospital.address2,
                                       :postalcode => hospital.postalcode,
                                       :city => hospital.city,
                                       :province => hospital.province,
                                       :phone1 => hospital.phone1,
                                       :fax => hospital.fax)
    }
  end
end
