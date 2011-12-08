class CreateSpecialistAddresses < ActiveRecord::Migration
  def change
    create_table :specialist_addresses do |t|
      t.integer :specialist_id
      t.integer :address_id
      
      t.timestamps
    end
    Specialist.all.each { 
      |specialist| specialist.offices.each { 
        |office| specialist.addresses.create(:address1 => office.address1,
                                             :address2 => office.address2,
                                             :postalcode => office.postalcode,
                                             :city => office.city,
                                             :province => office.province,
                                             :phone1 => office.phone1,
                                             :fax => office.fax)
      } 
    }
  end
end
