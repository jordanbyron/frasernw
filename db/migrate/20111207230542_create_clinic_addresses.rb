class CreateClinicAddresses < ActiveRecord::Migration
  def change
    create_table :clinic_addresses do |t|
      t.integer :clinic_id
      t.integer :address_id
      t.integer :hospital_id
      t.timestamps
    end
    Clinic.all.each { 
      |clinic| clinic.addresses.create(:address1 => clinic.address1,
                                       :address2 => clinic.address2,
                                       :postalcode => clinic.postalcode,
                                       :city => clinic.city,
                                       :province => clinic.province,
                                       :phone1 => clinic.phone1,
                                       :fax => clinic.fax)
    }
  end
end
