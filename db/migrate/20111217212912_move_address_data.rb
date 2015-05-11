class MoveAddressData < ActiveRecord::Migration
  def change

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

    Clinic.all.each {
      |clinic| clinic.addresses.create(:address1 => clinic.address1,
                                       :address2 => clinic.address2,
                                       :postalcode => clinic.postalcode,
                                       :city => clinic.city,
                                       :province => clinic.province,
                                       :phone1 => clinic.phone1,
                                       :fax => clinic.fax)
    }

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
