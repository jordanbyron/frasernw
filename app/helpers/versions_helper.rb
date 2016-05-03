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
      specialization_version =
        link_to version.item.name,
        specialization_path(version.item_id),
        class: 'specialty ajax'
      associated_specialization =
        link_to version.item.specialization.name,
        specialization_path(version.item.specialization),
        class: 'ajax'
      disassociated_specialization =
        link_to version.reify.specialization.name,
        specialization_path(version.reify.specialization),
        class: 'ajax'
      specialist_version =
        link_to version.item.name,
        specialist_path(version.item_id),
        class: 'specialist ajax'
      associated_specialist =
        link_to version.item.specialist.name,
        specialist_path(version.item.specialist),
        class: 'specialist ajax'
      disassociated_specialist =
        link_to version.reify.specialist.name,
        specialist_path(version.reify.specialist),
        class: 'specialist ajax'
      associated_office =
        link_to version.item.office.short_address,
        office_path(version.item.office),
        class: 'ajax'
      procedure_version =
        link_to version.item.name,
        procedure_path(version.item_id),
        class: 'procedure ajax'
      version_procedure =
        link_to version.item.procedure.name,
        procedure_path(version.item.procedure),
        class: 'procedure ajax'
      associated_procedure =
        link_to version.item.procedure_specialization.procedure.name,
        procedure_path(version.item.procedure_specialization.procedure),
        class: 'ajax'
      disassociated_procedure =
        link_to version.reify.procedure_specialization.procedure.name,
        procedure_path(version.reify.procedure_specialization.procedure),
        class: 'ajax'
      clinic_version =
        link_to version.item.name,
        clinic_path(version.item_id),
        class: 'clinic ajax'
      disassociated_clinic_version =
        link_to version.reify.name,
        version_path(version.item_id),
        class: 'clinic ajax'
      associated_clinic =
        link_to version.item.clinic.name,
        clinic_path(version.item.clinic),
        class: 'ajax'
      disassociated_clinic =
        link_to version.reify.clinic.name,
        clinic_path(version.reify.clinic),
        class: 'clinic ajax'
      language_version =
        link_to version.item.name,
        language_path(version.item_id),
        class: 'language ajax'
      version_language =
        link_to version.item.language.name,
        language_path(version.item_id),
        class: 'ajax'
      associated_language =
        link_to version.item.language.name,
        language_path(version.item.language),
        class: 'ajax'
      hospital_version =
        link_to version.item.name,
        hospital_path(version.item_id),
        class: 'hospital ajax'
      associated_hospital =
        link_to version.item.hospital.name,
        hospital_path(version.item.hospital),
        class: 'ajax'
      associated_location =
        version.item.location.short_address
      healthcare_provider_version =
        link_to version.item.name,
        healthcare_provider_path(version.item_id),
        class: 'clinic ajax'
      version_schedule =
        version.item.days_and_hours.to_sentence
      specialist_office_version =
        link_to version.item.schedulable.specialist.name,
        url_for(version.item.schedulable.specialist),
        class: 'ajax'
      clinic_location_version =
        link_to version.item.schedulable.clinic.name,
        url_for(version.item.schedulable.clinic),
        class: 'ajax'
      case version.item_type
        when "Specialization"
          if version.event == "create"
            "#{specialization_version} was created"
          elsif version.event == "update"
            "#{specialization_version} was updated"
          else
            link_to(
              version.reify.name,
              version_path(version.item_id),
              class: 'specialty ajax'
            ) + " was deleted"
          end
        when "Specialist"
          if version.event == "create"
            "#{specialist_version} was created"
          elsif version.event == "update"
            "#{specialist_version} was updated"
          else
            link_to(
              version.reify.name,
              version_path(version.item_id),
              class: 'specialist ajax'
            ) + " was deleted"
          end
        when "SpecialistSpecialization"
          if version.event == "create"
            associated_specialist + " now specializes in " + associated_specialization
          elsif version.event == "update"
            associated_specialist + "'s speciality in " + associated_specialization + " was updated"
          else
            "#{disassociated_specialist} no longer specializes in #{disassociated_specialization}"
          end
        when "SpecialistOffice"
          if version.event == "create"
            if version.item.office.present?
              "#{associated_specialist} now works in office #{associated_office}"
            else
              ""
            end
          elsif version.event == "update"
            if version.item.office.present?
              "#{associated_specialist}'s office in #{associated_office} was updated"
            else
              "#{associated_specialist}'s office was deleted"
            end
          else
            if version.reify.office.present?
              disassociated_specialist + " no longer works in office " + link_to version.reify.office.short_address, office_path(version.reify.office), class: 'ajax'
            else
              ""
            end
          end
        when "SpecialistAddress"
          ""
        when "Capacity"
          if version.event == "create"
            "#{associated_specialist} now performs #{associated_procedure}"
          elsif version.event == "update"
            "#{associated_specialist}'s area of practice #{associated_procedure} was updated"
          else
            "#{disassociated_specialist} no longer performs #{disassociated_procedure}"
          end
        when "Attendance"
          if version.event == "create"
            "#{associated_specialist} now works in #{associated_clinic}"
          elsif version.event == "update"
            "#{associated_specialist}'s association with clinic #{associated_clinic} was updated"
          else
            link_to version.reify.specialist.name, version_path(version.reify.specialist), class: 'specialist ajax' + " no longer works in " + link_to version.reify.clinic.name, clinic_path(version.reify.clinic), class: 'ajax'
          end
        when "SpecialistSpeak"
          if version.event == "create"
            "#{associated_specialist}'s office now speaks #{associated_language}"
          elsif version.event == "update"
            "#{associated_specialist}'s office language #{associated_language} was updated"
          else
            "#{disassociated_specialist}'s office no longer speaks #{associated_language}"
          end
        when "Privilege"
          if version.event == "create"
            "#{associated_specialist} now has hospital priviledge at #{associated_hospital}"
          elsif version.event == "update"
            "#{associated_specialist}'s hospital priviledges at #{associated_hospital} were updated"
          else
            "#{disassociated_specialist} no longer has hospital priviledge at " + link_to version.reify.hospital.name, hospital_path(version.item.hospital), class: 'ajax'
          end
        when "Clinic"
          if version.event == "create"
            "#{clinic_version} was created"
          elsif version.event == "update"
            "#{clinic_version} was updated"
          else
            "#{disassociated_clinic_version} was deleted"
          end
        when "ClinicLocation"
          if version.event == "create"
            if version.item.location.present?
              "#{associated_clinic} now works in #{associated_location}"
            else
              ""
            end
          elsif version.event == "update"
            if version.item.location.present?
              "#{associated_clinic}'s location at #{associated_location} was updated"
            else
              "#{associated_clinic}'s office was deleted"
            end
          else
            if version.reify.location.present?
              "#{disassociated_clinic} no longer located at #{associated_location}"
            else
              ""
            end
          end
        when "ClinicAddress"
          ""
        when "ClinicSpecialization"
          if version.event == "create"
            "#{associated_clinic} now specializes in #{associated_specialization}"
          elsif version.event == "update"
            "#{associated_clinic} speciality in #{associated_specialization} was updated"
          else
            "#{disassociated_clinic} no longer specializes in " + link_to version.reify.specialization.name, specialization_path(version.item.specialization), class: 'ajax'
          end
        when "Focus"
          if version.event == "create"
            "#{associated_clinic} now performs #{associated_procedure}"
          elsif version.event == "update"
            "#{associated_clinic} area of practice #{associated_procedure} was updated"
          else
            "#{disassociated_clinic} no longer performs #{disassociated_procedure}"
          end
        when "ClinicSpeak"
          if version.event == "create"
            "#{associated_clinic}'s office now speaks #{associated_language}"
          elsif version.event == "update"
            "#{associated_clinic}'s office languages #{version_language} was updated"
          else
            "#{disassociated_clinic}'s office no longer speaks #{version_language}"
          end
        when "ClinicHealthcareProvider"
          if version.event == "create"
            "#{associated_clinic} now has healthcare provider " + link_to version.item.healthcare_provider.name, healthcare_provider_path(version.item.healthcare_provider), class: 'ajax'
          elsif version.event == "update"
            "#{associated_clinic}'s healthcare provider " + link_to version.item.healthcare_provider.name, healthcare_provider_path(version.item_id), class: 'ajax' + " was updated"
          else
            "#{disassociated_clinic} no longer has healthcare provider " + link_to version.reify.healthcare_provider.name, healthcare_provider_path(version.item_id), class: 'ajax'
          end
        when "Hospital"
          if version.event == "create"
            "#{hospital_version} was created"
          elsif version.event == "update"
            "#{hospital_version} was updated"
          else
            link_to version.reify.name, version_path(version.item_id), class: 'hospital ajax' + " was deleted"
          end
        when "HospitalAddress"
          ""
        when "Address"
          ""
        when "Location"
          ""
        when "Office"
          ""
        when "Procedure"
          if version.event == "create"
            "#{procedure_version} was created"
          elsif version.event == "update"
            "#{procedure_version} was updated"
          else
            link_to version.reify.name, version_path(version.item_id), class: 'procedure ajax' + " was deleted"
          end
        when "ProcedureSpecialization"
          if version.event == "create"
            if version.item.mapped
              "#{version_procedure} is now performed by #{associated_specialization}"
            else
              return ""
            end
          elsif version.event == "update"
            if version.reify.mapped
              "#{version_procedure} specialty in #{associated_specialization} was updated"
            else
              return ""
            end
          else
            if version.reify.mapped
              link_to version.reify.procedure.name, procedure_path(version.reify.procedure), class: 'procedure ajax' + " is no longer performed by #{disassociated_specialization}"
            else
              return ""
            end
          end
        when "Language"
          if version.event == "create"
            "#{language_version} was created"
          elsif version.event == "update"
            "#{language_version} was updated"
          else
            link_to version.reify.name, version_path(version.item_id), class: 'language ajax' + " was deleted"
          end
        #HEALTHCARE PROVIDERS
        when "HealthcareProvider"
          if version.event == "create"
            "#{healthcare_provider_version} was created"
          elsif version.event == "update"
            "#{healthcare_provider_version} was updated"
          else
            "#{disassociated_clinic_version} was deleted"
          end
        when "Schedule"
          if version.event == "create" || version.event == "update"
            if version.item.days_and_hours.length == 0
              ""
            elsif version.item.schedulable.is_a? SpecialistOffice
              "#{specialist_office_version} has the schedule: #{version_schedule}"
            elsif version.item.schedulable.is_a? ClinicLocation
              "#{clinic_location_version} has the schedule: #{version_schedule}"
            else
              ""
            end
          else
            if version.item.schedulable.is_a? SpecialistOffice
              "#{specialist_office_version} no longer has a schedule"
            elsif version.item.schedulable.is_a? ClinicLocation
              "#{clinic_location_version} no longer has a schedule"
            else
              ""
            end
          end
        when "ScheduleDay"
          #handled by Schedule
          ""
        when "UserControlsClinicLocation"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.user.name, user_path(version.item.user_id), class: 'user ajax'} has the ability to edit #{link_to version.item.clinic_location.clinic.name, clinic_path(version.item.clinic_location.clinic_id), class: 'clinic ajax'}"
          else
            "#{link_to version.reify.user.name, user_path(version.reify.user_id), class: 'user ajax'} no longer has the ability to edit #{link_to version.reify.clinic_location.clinic.name, clinic_path(version.reify.clinic_location.clinic_id), class: 'clinic ajax'}"
          end
        when "UserControlsSpecialistOffice"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.user.name, user_path(version.item.user_id), class: 'user ajax'} has the ability to edit #{link_to version.item.specialist_office.specialist.name, specialist_path(version.item.specialist_office.specialist_id), class: 'specialist ajax'}"
          else
            "#{link_to version.reify.user.name, user_path(version.reify.user_id), class: 'user ajax'} no longer has the ability to edit #{link_to version.reify.specialist_office.specialist.name, specialist_path(version.item.specialist_office.specialist_id), class: 'specialist ajax'}"
          end
        when "SpecializationOption"
          if version.event == "create" || version.event == "update"
            "The options for #{link_to version.item.specialization.name, specialization_path(version.item.specialization_id), class: 'specialty ajax'} in division #{link_to version.item.division.name, division_path(version.item.division_id), class: 'division ajax'} have changed"
          end
        when "Division"
          if version.event == "create"
            "#{link_to version.item.name, division_path(version.item_id), class: 'division ajax'} was created"
          elsif version.event == "update"
            "#{link_to version.item.name, division_path(version.item_id), class: 'division ajax'} was updated"
          else
            "#{link_to version.reify.name, show_division_path(version.item_id), class: 'division ajax'} was deleted"
          end
        when "DivisionUser"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.user.name, user_path(version.item.user_id), class: 'user ajax'} is now a member of #{link_to version.item.division.name, division_path(version.item.division_id), class: 'division ajax'}"
          else
            "#{link_to version.reify.user.name, user_path(version.reify.user_id), class: 'user ajax'} is no longer a member of #{link_to version.reify.division.name, division_path(version.reify.division_id), class: 'division ajax'}"
          end
        when "DivisionDisplayScItem"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.division.name, division_path(version.item.division_id), class: 'division ajax'} is now sharing the content item #{link_to version.item.sc_item.title, sc_item_path(version.item.sc_item_id), class: 'sc_item ajax'}"
          else
            "#{link_to version.reify.division.name, division_path(version.reify.division_id), class: 'division ajax'} is no longer sharing the content item #{link_to version.reify.sc_item.title, sc_item_path(version.reify.sc_item_id), class: 'sc_item ajax'}"
          end
        when "DivisionReferralCitySpecialization"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.division_referral_city.division.name, division_path(version.item.division_referral_city.division_id), class: 'division ajax'} now has #{version.item.division_referral_city.city.name} in their local referral area for #{link_to version.item.specialization.name, specialization_path(version.item.specialization_id), class: 'specialty ajax'}"
          end
        when "DivisionReferralCity"
          #handled by DivisionReferralCitySpecialization
          ""
        when "DivisionCity"
          if version.event == "create" || version.event == "update"
            "#{link_to version.item.division.name, division_path(version.item.division_id), class: 'division ajax'} now owns #{version.item.city.name}"
          end
        when "ReferralForm"
          ""
        when "Secret Token"
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
