module VersionsHelper
  def whodunnit_name(version)
    if version.terminator.to_i.to_s == version.terminator
      if User.find_by_id(version.terminator).present?
        User.find_by_id(version.terminator).name
      else
        'unknown'
      end
    elsif version.whodunnit == "MOA"
      version.whodunnit
    else
      'unknown'
    end
  end

  def version_event(version)
    begin
      case version.item_type
        #SPECIALIZATIONS
        when "Specialization"
          if version.event == "create"
            "#{link_to version.item.name, specialization_path(version.item_id), :class => 'specialty ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, specialization_path(version.item_id), :class => 'specialty ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'specialty ajax'} was deleted"
        end
        #SPECIALISTS
        when "Specialist"
          if version.event == "create"
            "#{link_to version.item.name, specialist_path(version.item_id), :class => 'specialist ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, specialist_path(version.item_id), :class => 'specialist ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'specialist ajax'} was deleted"
          end
        when "SpecialistSpecialization"
          if version.event == "create"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'} now specializes in #{link_to version.item.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s speciality in #{link_to version.item.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.specialist.name, specialist_path(version.reify.specialist), :class => 'specialist ajax'} no longer specializes in #{link_to version.reify.specialization.name, specialization_path(version.reify.specialization), :class => 'ajax'}"
          end
        when "SpecialistOffice"
          if version.event == "create"
            if version.item.office.present?
              "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'} now works in office #{link_to version.item.office.short_address, office_path(version.item.office), :class => 'ajax'}"
            else
              ""
            end
          elsif version.event == "update"
            if version.item.office.present?
              "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s office in #{link_to version.item.office.short_address, office_path(version.item.office), :class => 'ajax'} was updated"
            else
              "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s office was deleted"
            end
          else
            if version.reify.office.present?
              "#{link_to version.reify.specialist.name, specialist_path(version.reify.specialist), :class => 'specialist ajax'} no longer works in office #{link_to version.reify.office.short_address, office_path(version.reify.office), :class => 'ajax'}"
            else
              ""
            end
          end
        when "SpecialistAddress"
          #handled by Address
          ""
        when "Capacity"
          if version.event == "create"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'} now performs #{link_to version.item.procedure_specialization.procedure.name, procedure_path(version.item.procedure_specialization.procedure), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s area of practice #{link_to version.item.procedure_specialization.procedure.name, procedure_path(version.item.procedure_specialization.procedure), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.specialist.name, specialist_path(version.reify.specialist), :class => 'specialist ajax'} no longer performs #{link_to version.reify.procedure_specialization.procedure.name, procedure_path(version.reify.procedure_specialization.procedure), :class => 'ajax'}"
          end
        when "Attendance"
          if version.event == "create"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'} now works in #{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s association with clinic #{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.specialist.name, version_path(version.reify.specialist), :class => 'specialist ajax'} no longer works in #{link_to version.reify.clinic.name, clinic_path(version.reify.clinic), :class => 'ajax'}"
          end
        when "SpecialistSpeak"
          if version.event == "create"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s office now speaks #{link_to version.item.language.name, language_path(version.item.language), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s office language #{link_to version.item.language.name, language_path(version.item.language), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.specialist.name, specialist_path(version.reify.specialist), :class => 'specialist ajax'}'s office no longer speaks #{link_to version.item.language.name, language_path(version.item.language), :class => 'ajax'}"
          end
        when "Privilege"
          if version.event == "create"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'} now has hospital priviledge at #{link_to version.item.hospital.name, hospital_path(version.item.hospital), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.specialist.name, specialist_path(version.item.specialist), :class => 'specialist ajax'}'s hospital priviledges at #{link_to version.item.hospital.name, hospital_path(version.item.hospital), :class => 'ajax'} were updated"
          else
            "#{link_to version.reify.specialist.name, specialist_path(version.reify.specialist), :class => 'specialist ajax'} no longer has hospital priviledge at #{link_to version.reify.hospital.name, hospital_path(version.item.hospital), :class => 'ajax'}"
          end
        #CLINICS
        when "Clinic"
          if version.event == "create"
            "#{link_to version.item.name, clinic_path(version.item_id), :class => 'clinic ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, clinic_path(version.item_id), :class => 'clinic ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'clinic ajax'} was deleted"
          end
        when "ClinicLocation"
          if version.event == "create"
            if version.item.location.present?
              "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'} now works in #{version.item.location.short_address}"
            else
              ""
            end
          elsif version.event == "update"
            if version.item.location.present?
              "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'}'s location at #{version.item.location.short_address} was updated"
            else
              "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'}'s office was deleted"
            end
          else
            if version.reify.location.present?
              "#{link_to version.reify.clinic.name, clinic_path(version.reify.clinic), :class => 'clinic ajax'} no longer located at #{version.item.location.short_address}"
            else
              ""
            end
          end
        when "ClinicAddress"
          #handled by Address
          ""
        when "ClinicSpecialization"
          if version.event == "create"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'} now specializes in #{link_to version.item.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'} speciality in #{link_to version.item.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.clinic.name, clinic_path(version.reify.clinic), :class => 'clinic ajax'} no longer specializes in #{link_to version.reify.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'}"
          end
        when "Focus"
          if version.event == "create"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'} now performs #{link_to version.item.procedure_specialization.procedure.name, procedure_path(version.item.procedure_specialization.procedure), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'} area of practice #{link_to version.item.procedure_specialization.procedure.name, procedure_path(version.item.procedure_specialization.procedure), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.clinic.name, clinic_path(version.reify.clinic), :class => 'clinic ajax'} no longer performs #{link_to version.reify.procedure_specialization.procedure.name, procedure_path(version.reify.procedure_specialization.procedure), :class => 'ajax'}"
          end
        when "ClinicSpeak"
          if version.event == "create"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'}'s office now speaks #{link_to version.item.language.name, language_path(version.item.language), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'}'s office languages #{link_to version.item.language.name, language_path(version.item_id), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.clinic.name, clinic_path(version.reify.clinic), :class => 'clinic ajax'}'s office no longer speaks #{link_to version.item.language.name, language_path(version.item_id), :class => 'ajax'}"
          end
        when "ClinicHealthcareProvider"
          if version.event == "create"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'} now has healthcare provider #{link_to version.item.healthcare_provider.name, healthcare_provider_path(version.item.healthcare_provider), :class => 'ajax'}"
          elsif version.event == "update"
            "#{link_to version.item.clinic.name, clinic_path(version.item.clinic), :class => 'clinic ajax'}'s healthcare provider #{link_to version.item.healthcare_provider.name, healthcare_provider_path(version.item_id), :class => 'ajax'} was updated"
          else
            "#{link_to version.reify.clinic.name, clinic_path(version.reify.clinic), :class => 'clinic ajax'} no longer has healthcare provider #{link_to version.reify.healthcare_provider.name, healthcare_provider_path(version.item_id), :class => 'ajax'}"
          end
        #HOSPITALS
        when "Hospital"
          if version.event == "create"
            "#{link_to version.item.name, hospital_path(version.item_id), :class => 'hospital ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, hospital_path(version.item_id), :class => 'hospital ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'hospital ajax'} was deleted"
          end
        when "HospitalAddress"
          #handled by Address
          ""
        #ADDRESSES
        when "Address"
          #TODO
          ""
        when "Location"
          #TODO
          ""
        when "Office"
          #TODO
          ""
        #PROCEDURES
        when "Procedure"
          if version.event == "create"
            "#{link_to version.item.name, procedure_path(version.item_id), :class => 'procedure ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, procedure_path(version.item_id), :class => 'procedure ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'procedure ajax'} was deleted"
          end
        when "ProcedureSpecialization"
          if version.event == "create"
            if version.item.mapped
              "#{link_to version.item.procedure.name, procedure_path(version.item.procedure), :class => 'procedure ajax'} is now performed by #{link_to version.item.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'}"
            else
              #we create a lot of unmapped procedurespecializations
              return ""
            end
          elsif version.event == "update"
            if version.reify.mapped
              "#{link_to version.item.procedure.name, procedure_path(version.item.procedure), :class => 'procedure ajax'} specialty in #{link_to version.item.specialization.name, specialization_path(version.item.specialization), :class => 'ajax'} was updated"
            else
              #we create a lot of unmapped procedurespecializations
              return ""
            end
          else
            if version.reify.mapped
              "#{link_to version.reify.procedure.name, procedure_path(version.reify.procedure), :class => 'procedure ajax'} is no longer performed by #{link_to version.reify.specialization.name, specialization_path(version.reify.specialization), :class => 'ajax'}"
            else
              #we create a lot of unmapped procedurespecializations
              return ""
            end
          end
        #LANGAUGES
        when "Language"
          if version.event == "create"
            "#{link_to version.item.name, language_path(version.item_id), :class => 'language ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, language_path(version.item_id), :class => 'language ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'language ajax'} was deleted"
          end
        #HEALTHCARE PROVIDERS
        when "HealthcareProvider"
          if version.event == "create"
            "#{link_to version.item.name, healthcare_provider_path(version.item_id), :class => 'clinic ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, healthcare_provider_path(version.item_id), :class => 'clinic ajax'} was updated"
          else
            "#{link_to version.reify.name, version_path(version.item_id), :class => 'clinic ajax'} was deleted"
          end
        when "Schedule"
          if version.event == "create" || version.event == "update"
            if version.item.days_and_hours.length == 0
              ""
            elsif version.item.schedulable.is_a? SpecialistOffice
              "#{link_to version.item.schedulable.specialist.name, url_for(version.item.schedulable.specialist), :class => 'ajax'} has the schedule: #{version.item.days_and_hours.to_sentence}"
            elsif version.item.schedulable.is_a? ClinicLocation
              "#{link_to version.item.schedulable.clinic.name, url_for(version.item.schedulable.clinic), :class => 'ajax'} has the schedule: #{version.item.days_and_hours.to_sentence}"
            else
              ""
            end
          else
            if version.item.schedulable.is_a? SpecialistOffice
              "#{link_to version.item.schedulable.specialist.name, url_for(version.item.schedulable.specialist), :class => 'ajax'} no longer has a schedule"
            elsif version.item.schedulable.is_a? ClinicLocation
              "#{link_to version.item.schedulable.clinic.name, url_for(version.item.schedulable.clinic), :class => 'ajax'} no longer has a schedule"
            else
              ""
            end
          end
        when "ScheduleDay"
          #handled by Schedule
          ""
        when "UserControlsClinicLocation"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.user.name, user_path(version.item.user_id), :class => 'user ajax'} has the ability to edit #{link_to version.item.clinic_location.clinic.name, clinic_path(version.item.clinic_location.clinic_id), :class => 'clinic ajax'}"
          else
            "#{link_to version.reify.user.name, user_path(version.reify.user_id), :class => 'user ajax'} no longer has the ability to edit #{link_to version.reify.clinic_location.clinic.name, clinic_path(version.reify.clinic_location.clinic_id), :class => 'clinic ajax'}"
          end
        when "UserControlsSpecialistOffice"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.user.name, user_path(version.item.user_id), :class => 'user ajax'} has the ability to edit #{link_to version.item.specialist_office.specialist.name, specialist_path(version.item.specialist_office.specialist_id), :class => 'specialist ajax'}"
          else
            "#{link_to version.reify.user.name, user_path(version.reify.user_id), :class => 'user ajax'} no longer has the ability to edit #{link_to version.reify.specialist_office.specialist.name, specialist_path(version.item.specialist_office.specialist_id), :class => 'specialist ajax'}"
          end
        when "SpecializationOption"
          if version.event == "create" || version.event == "update"
            "The options for #{link_to version.item.specialization.name, specialization_path(version.item.specialization_id), :class => 'specialty ajax'} in division #{link_to version.item.division.name, division_path(version.item.division_id), :class => 'division ajax'} have changed"
          end
        when "Division"
          if version.event == "create"
            "#{link_to version.item.name, division_path(version.item_id), :class => 'division ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, division_path(version.item_id), :class => 'division ajax'} was updated"
          else
            "#{link_to version.reify.name, show_division_path(version.item_id), :class => 'division ajax'} was deleted"
          end
        when "DivisionUser"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.user.name, user_path(version.item.user_id), :class => 'user ajax'} is now a member of #{link_to version.item.division.name, division_path(version.item.division_id), :class => 'division ajax'}"
          else
            "#{link_to version.reify.user.name, user_path(version.reify.user_id), :class => 'user ajax'} is no longer a member of #{link_to version.reify.division.name, division_path(version.reify.division_id), :class => 'division ajax'}"
          end
        when "DivisionDisplayScItem"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.division.name, division_path(version.item.division_id), :class => 'division ajax'} is now sharing the content item #{link_to version.item.sc_item.title, sc_item_path(version.item.sc_item_id), :class => 'sc_item ajax'}"
          else
            "#{link_to version.reify.division.name, division_path(version.reify.division_id), :class => 'division ajax'} is no longer sharing the content item #{link_to version.reify.sc_item.title, sc_item_path(version.reify.sc_item_id), :class => 'sc_item ajax'}"
          end
        when "DivisionReferralCitySpecialization"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.division_referral_city.division.name, division_path(version.item.division_referral_city.division_id), :class => 'division ajax'} now has #{version.item.division_referral_city.city.name} in their local referral area for #{link_to version.item.specialization.name, specialization_path(version.item.specialization_id), :class => 'specialty ajax'}"
          end
        when "DivisionReferralCity"
          #handled by DivisionReferralCitySpecialization
          ""
        when "DivisionCity"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.division.name, division_path(version.item.division_id), :class => 'division ajax'} now owns #{version.item.city.name}"
          end
        when "ReferralForm"
          ""
        else
          "TODO: #{version.item_type}"
      end
      rescue Exception => exc
      #"This item (#{version.reify.respond_to?('name') ? version.reify.name + ', ' + version.item_type : version.item_type}) was deleted after the change was made: #{exc.message}"
        "This item (#{version.reify.respond_to?('name') ? version.reify.name + ', ' + version.item_type : version.item_type}) was deleted after the change was made"
    end
  end

  def translate_changes(version, attribute, changeset)
    return 'Yes' if changeset == true
    return 'No' if changeset == false
    begin
      I18n.translate("#{version.item_type.constantize.i18n_scope}.values.#{version.item_type.constantize.model_name.i18n_key}.#{attribute}.#{changeset}", raise: I18n::MissingTranslationData)
    rescue I18n::MissingTranslationData
      changeset
    end
  end
end
