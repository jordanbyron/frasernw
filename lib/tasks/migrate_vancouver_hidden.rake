namespace :pathways do
  task migrate_vancouver_hidden: :environment do
    vancouverHiddenDivision = Division.find_by_name("Vancouver (Hidden)")
    vancouverHiddenCity = City.find_by_name("Vancouver (Hidden)")

    vancouverDivision = Division.find_by_name("Vancouver")
    vancouverCity = City.find_by_name("Vancouver")

    Hospital.all.each do |h|
      next if h.name.blank?
      h.name = h.name.strip
      h.save
    end

    Clinic.all.each do |c|
      next if c.name.blank?
      c.name = c.name.strip
      c.save
    end

    puts "--------------- Hospitals ---------------"

    Hospital.in_divisions([vancouverHiddenDivision]).each do |hospital|
      other_hospitals = Hospital.where(name: hospital.name).reject do |h|
        !h.city || (h.city.id == vancouverHiddenCity.id)
      end
      if other_hospitals.length >= 1

        if other_hospitals.length >= 2
          puts "ERROR: Found more than one hospital with the name #{hospital.name}"
        end

        other_hospital = other_hospitals.first

        puts "Found duplicate hospital #{other_hospital.name} at "\
          "#{other_hospital.short_address}"

        hospital.locations_in.each do |location|

          if (
            location.locatable.present? &&
              (location.locatable_type == "ClinicLocation") &&
              location.locatable.clinic.present? &&
              (Clinic.where(name: location.locatable.clinic.name).reject do |other_clinic|
                (other_clinic.id == location.locatable.clinic.id) ||
                (other_clinic.locations.reject{ |l|
                  l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id)
                }.length == 0)
              end.length >= 1)
            )

            puts "- leaving duplicate clinic #{location.locatable.clinic.name} in "\
              "Vancouver (Hidden) to be merged later"
          else
            puts "- migrating #{location.full_address} to #{other_hospital.short_address}"
            location.hospital_in_id = other_hospital.id
            location.save
          end

        end

        hospital.privileges.each do |privilege|
          next if privilege.specialist.blank?
          puts "- migrating #{privilege.specialist.name} to "\
            "#{other_hospital.short_address}"
          privilege.hospital = other_hospital
          privilege.save
        end

      else
        address = hospital.address
        puts "Moving #{hospital.name} at #{hospital.short_address} to Vancouver"
        address.city = vancouverCity
        address.save

        # if there are clinics attached that are duplicates, move them back into
        # Vancouver (Hidden) so they will merge with their non-duplicate below
        hospital.locations_in.each do |location|
          if (
            location.locatable.present? &&
              (location.locatable_type == "ClinicLocation") &&
              location.locatable.clinic.present? &&
              (Clinic.where(name: location.locatable.clinic.name).reject do |other_clinic|
                (other_clinic.id == location.locatable.clinic.id) ||
                (other_clinic.locations.reject{ |l|
                  l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id)
                }.length == 0)
              end.length >= 1)
          )
            puts "- migrating clinic #{clinic.name} back to Vancouver (Hidden) "\
              "to merge later"
            location.hospital_in = nil
            location.address = Address.create :city_id => vancouverHiddenCity.id
            location.save
          end
        end
      end
    end

    puts "--------------- Clinics ---------------"

    Clinic.in_divisions([vancouverHiddenDivision]).each do |clinic|

      if clinic.locations.reject do |l|
        l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id)
      end.length > 0
        puts "ERROR: clinic #{clinic.name} that we are migrating from has locations "\
          "outside of Vancouver (Hidden)"
      end

      # possible other clinics are those that have the same name but have locations
      # outside of Vancouver (Hidden)
      other_clinics = Clinic.where(name: clinic.name).reject do |other_clinic|
        (other_clinic.id == clinic.id) || (other_clinic.locations.reject do |l|
          l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id)
        end.length == 0)
      end

      if other_clinics.length >= 1

        #this clinic is a duplicate in Vancouver (Hidden), sort that out

        if other_clinics.length >= 2
          puts "ERROR: Found more than one clinic with the name #{clinic.name}"
        end

        other_clinic = other_clinics.first

        puts "Found duplicate clinic #{other_clinic.name}"

        if other_clinic.locations.reject do |l|
          l.blank? || l.city.blank? || (l.city.id == vancouverHiddenCity.id)
        end.length == 0
          puts "ERROR: clinic #{other_clinic.name} that we are migrating to has no "\
            "valid locations"
        end

        other_vancouver_clinic_locations = other_clinic.clinic_locations.reject do |cl|
          cl.blank? ||
          cl.location.blank? ||
          cl.location.city.blank? ||
          (cl.location.city.id != vancouverCity.id)
        end

        if other_vancouver_clinic_locations.length == 0
          puts "ERROR: clinic #{other_clinic.name} that we are migrating to has no "\
            "location in Vancouver"
          next
        end

        other_vancouver_clinic_location = other_vancouver_clinic_locations.first

        clinic.clinic_locations.reject do |cl|
          cl.blank? ||
          cl.location.blank? ||
          cl.location.city.blank? ||
          (cl.location.city.id != vancouverHiddenCity.id)
        end.each do |clinic_location|

          #move any specialists and offices in this clinic location to the duplicate
          clinic_location.location.locations_in.each do |location_in|
            puts "- migrating #{location_in.full_address} to "\
              "#{other_vancouver_clinic_location.location.full_address}"
            location_in.location_in_id = other_vancouver_clinic_location.location.id
            location_in.save
          end

          #move any 'associated' specialists in this location to the duplicate
          clinic_location.clinic_specialists.each do |clinic_specialist|
            next if clinic_specialist.specialist.blank?
            puts "- moving specialist #{clinic_specialist.specialist.name} to "\
              "#{other_vancouver_clinic_location.location.short_address}"
            clinic_specialist.clinic_location = other_vancouver_clinic_location
            clinic_specialist.save
          end
        end

      else

        #this clinic is not a duplicate, move it to Vancouver

        clinic.locations.each do |location|
          next if (
            location.empty? ||
            location.blank? ||
            location.city.blank? ||
            (location.city.id != vancouverHiddenCity.id)
          )

          if location.in_hospital?
            puts "ERROR: clinic #{clinic.name} at #{location.short_address} is still "\
              "in a hospital that is in Vancouver (Hidden)"
            next
          end

          puts "Migrating #{clinic.name} at #{location.short_address} to Vancouver"
          address = location.address
          address.city = vancouverCity
          address.save
        end
      end
    end

    puts "--------------- Specialists ---------------"

    Specialist.in_divisions([vancouverHiddenDivision]).each do |specialist|

      puts specialist.name

      specialist.specialist_offices.reject do |so|
        so.blank? ||
        so.office.blank? ||
        so.office.location.blank? ||
        so.office.location.city.blank? ||
        (so.office.location.city.id != vancouverHiddenCity.id)
      end.each do |specialist_office|

        if specialist_office.office.location.in_hospital?
          puts "ERROR: specialist #{specialist.name} at "\
            "#{specialist_office.office.location.short_address} is "\
            "still in a hospital that is in Vancouver (Hidden)"
          next
        end

        if specialist_office.office.location.in_clinic?
          puts "ERROR: specialist #{specialist.name} at "\
            "#{specialist_office.office.location.short_address} is "\
            "still in a clinic that is in Vancouver (Hidden)"
          next
        end

        specialist_address = specialist_office.office.location.address

        puts "- migrating #{specialist.name} at "\
          "#{specialist_office.office.location.short_address} to Vancouver"
        address = specialist_office.office.location.address
        address.city = vancouverCity
        address.save
      end
    end
  end
end
