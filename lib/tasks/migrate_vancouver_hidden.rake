namespace :pathways do
  task :migrate_vancouver_hidden => :environment do
    vancouverHiddenDivision = Division.find_by_name("Vancouver (Hidden)")
    vancouverHiddenCity = City.find_by_name("Vancouver (Hidden)")

    vancouverDivision = Division.find_by_name("Vancouver")
    vancouverCity = City.find_by_name("Vancouver")

    #todo:
    #trim all hospital and clinic names first?

    puts "--------------- Clinics ---------------"

    Clinic.in_divisions([vancouverHiddenDivision]).each do |clinic|

      if clinic.locations.reject{ |l| l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id) }.length > 0
        puts "ERROR: clinic #{clinic.name} that we are migrating from has locations outside of Vancouver (Hidden)"
      end

      #possible other clinics are those that have the same name but have locations outside of Vancouver (Hidden)
      other_clinics = Clinic.find_all_by_name(clinic.name).reject{ |other_clinic| (other_clinic.id == clinic.id) || (other_clinic.locations.reject{ |l| l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id) }.length == 0) }

      if other_clinics.length >= 1

        #this clinic is a duplicate in Vancouver (Hidden), sort that out

        if other_clinics.length >= 2
          puts "ERROR: Found more than one clinic with the name #{clinic.name}"
        end

        other_clinic = other_clinics.first

        puts "Found duplicate clinic #{other_clinic.name}"

        if other_clinic.locations.reject{ |l| l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id) }.length == 0
          puts "ERROR: clinic #{other_clinic.name} that we are migrating to has no valid locations"
        end

        other_vancouver_clinic_locations = other_clinic.clinic_locations.reject{ |cl| cl.blank? || cl.location.blank? || cl.location.city.blank? || (cl.location.city.id != vancouverCity.id) }

        if other_vancouver_clinic_locations.length == 0
          puts "ERROR: clinic #{other_clinic.name} that we are migrating to has no location in Vancouver"
          next
        end

        other_vancouver_clinic_location = other_vancouver_clinic_locations.first

        clinic.clinic_locations.reject{ |cl| cl.blank? || cl.location.blank? || cl.location.city.blank? || (cl.location.city.id != vancouverHiddenCity.id) }.each do |clinic_location|

          #move any specialists and offices in this clinic location to the duplicate
          clinic_location.location.locations_in.each do |location_in|
            puts "- migrating #{location_in.full_address} to #{other_vancouver_clinic_location.location.full_address}"
            location_in.location_in_id = other_vancouver_clinic_location.location.id
            location_in.save
          end

          #move any 'associated' specialists in this location to the duplicate
          clinic_location.attendances.each do |attendance|
            next if attendance.specialist.blank?
            puts "- moving specialist #{attendance.specialist.name} to #{other_vancouver_clinic_location.location.short_address}"
            attendance.clinic_location = other_vancouver_clinic_location
            attendance.save
          end
        end

      else

        #this clinic is not a duplicate, move it to Vancouver

        clinic.locations.each do |location|
          next if (location.empty? || location.blank? || location.city.blank? || (location.city.id != vancouverHiddenCity.id))

          puts "Migrating #{clinic.name} at #{location.short_address} to Vancouver"
          address = location.address
          address.city = vancouverCity
          address.save
        end
      end
    end

    puts "--------------- Hospitals ---------------"

    Hospital.in_divisions([vancouverHiddenDivision]).each do |hospital|
      other_hospitals = Hospital.find_all_by_name(hospital.name).reject{ |h| !h.city || (h.city.id == vancouverHiddenCity.id) }
      if other_hospitals.length >= 1

        if other_hospitals.length >= 2
          puts "ERROR: Found more than one hospital with the name #{hospital.name}"
        end

        other_hospital = other_hospitals.first

        puts "Found duplicate hospital #{other_hospital.name} at #{other_hospital.short_address}"

        hospital.locations_in.each do |location|
          puts "- migrating #{location.full_address} to #{other_hospital.short_address}"
          location.hospital_in_id = other_hospital.id
          location.save
        end

        hospital.privileges.each do |privilege|
          next if privilege.specialist.blank?
          puts "- migrating #{privilege.specialist.name} to #{other_hospital.short_address}"
          privilege.hospital = other_hospital
          privilege.save
        end

      else
        address = hospital.address
        puts "- migrating #{hospital.name} at #{hospital.short_address} to Vancouver"
        address.city = vancouverCity
        address.save
      end
    end

    puts "--------------- Specialists ---------------"

    vancouver_offices = Office.in_cities([vancouverCity])

    Specialist.in_divisions([vancouverHiddenDivision]).each do |specialist|

      puts specialist.name

      specialist.specialist_offices.reject{ |so| so.blank? || so.office.blank? || so.office.location.blank? || so.office.location.city.blank? || (so.office.location.city.id != vancouverHiddenCity.id) }.each do |specialist_office|

        if specialist_office.office.location.in_hospital?
          puts "ERROR: specialist #{specialist.name} at #{specialist_office.office.location.short_address} is still in a hospital that is in Vancouver (Hidden)"
          next
        end

        if specialist_office.office.location.in_clinic?
          puts "ERROR: specialist #{specialist.name} at #{specialist_office.office.location.short_address} is still in a hospital that is in Vancouver (Hidden)"
          next
        end

        specialist_address = specialist_office.office.location.address

        matching_offices = vancouver_offices.reject{ |office| (office.location.address.address1 != specialist_address.address1) || (office.location.address.address2 != specialist_address.address2) || (office.location.address.suite != specialist_address.suite) || (office.location.address.postalcode != specialist_address.postalcode) }

        if matching_offices.length >= 1

          if matching_offices.length >= 2
            puts "ERROR: Found more than one offcie with the address #{specialist_address.address}"
          end

          matching_office = matching_offices.first

          puts "- migrating #{specialist.name} at #{specialist_address.address} to #{matching_office.full_address}"
          specialist_office.office = matching_office
          specialist_office.save

        else

          puts "- migrating #{specialist.name} at #{specialist_office.office.location.short_address} to Vancouver"
          address = specialist_office.office.location.address
          address.city = vancouverCity
          address.save

        end
      end
    end

  end
end