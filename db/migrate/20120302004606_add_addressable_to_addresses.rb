class AddAddressableToAddresses < ActiveRecord::Migration
  def change

    add_column :hospitals, :phone, :string
    add_column :hospitals, :fax, :string
    Hospital.reset_column_information

    #make locations, which holds whether or not were in a clinic, hospital, or standalone address
    create_table :locations do |t|
      t.string  :locatable_type
      t.integer :locatable_id
      t.integer :address_id
      t.integer :hospital_in_id
      t.integer :clinic_in_id
      t.string  :suite_in
      t.string  :details_in

      t.timestamps
    end
    Location.reset_column_information

    #Hospitals have a single address, and aren't every in another clinic or hospital. Just copy over data

    HospitalAddress.all.each do |ha|

      next if ha.address.blank?
      next if ha.hospital.blank?
      next if ha.address.empty_old?

      a = ha.address
      h = ha.hospital

      h.build_location
      h.location.address = a
      h.phone = a.phone1
      h.fax = a.fax
      h.save
    end

    #todo DROP table hospital_addresses

    #clinics will only have a single address, or may be in a hopsital.

    add_column :clinics, :phone, :string
    add_column :clinics, :fax, :string
    Clinic.reset_column_information

    ClinicAddress.all.each do |ca|

      next if ca.address.blank?
      next if ca.clinic.blank?
      next if ca.address.empty_old?

      c = ca.clinic
      a = ca.address

      c.build_location
      c.phone = a.phone1
      c.fax = a.fax

      if a.hospital_id.present?

        #clinic was marked in a hospital, will use hospital address

        c.location.hospital_in_id = a.hospital_id
        c.location.suite_in = a.suite
        c.location.details_in = a.address2

        #hold the old address information in our information, in case there is value to it

        c.location.address = a;
        c.save

      else

        #clinic is stand alone, will have its own address entry

        c.location.address = a
        c.save

      end

    end

    #todo DROP table clinic_addresses

    #specialists can be in multiple offices, which have locations (they may be in a clinic or a hospital, or stand-alone).

    #drop old unused offices
    drop_table :offices;
    #todo old offices indexes

    #make offices
    create_table :offices do |t|
      t.timestamps
    end
    Office.reset_column_information

    #make specialist_offices
    create_table :specialist_offices do |t|
      t.integer :specialist_id
      t.integer :office_id
      t.string  :phone
      t.string  :fax

      t.timestamps
    end
    SpecialistOffice.reset_column_information

    SpecialistAddress.all.each do |sa|

      next if sa.address.blank?
      next if sa.specialist.blank?
      next if sa.address.empty_old?

      s = sa.specialist
      a = sa.address

      so = s.specialist_offices.build
      s.save
      so.phone = a.phone1
      so.fax = a.fax
      o = so.build_office
      so.save
      l = o.build_location
      o.save

      if a.hospital_id.present?

        #specialist was marked in a hospital, will use hospital address

        l.hospital_in_id = a.hospital_id
        l.suite_in = a.suite
        l.details_in = a.address2

        #hold the old address information in our information, in case there is value to it

        l.address = a;
        l.save

      elsif a.clinic_id.present?

        #specialist was marked in a clinic, will use clinic address

        l.clinic_in_id = a.clinic_id
        l.suite_in = a.suite
        l.details_in = a.address2

        #hold the old address information in our information, in case there is value to it

        l.address = a;
        l.save

      else

        #specialist is stand alone, will have its own address entry

        l.address = a
        l.save

      end

    end

    #todo DROP table specialist_addresses

  end
end
