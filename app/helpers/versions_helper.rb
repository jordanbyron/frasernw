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
    case version.item_type
      when "Specialization"
        if version.event == "create"
          link_to(version.item.name, specialization_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, specialization_path(version.item_id)) +
            " was updated"
        else
          link_to(version.reify.name, version_path(version.item_id)) +
            " was deleted"
        end
      when "Specialist"
        if version.event == "create"
          link_to(version.item.name, specialist_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, specialist_path(version.item_id)) +
            " was updated"
        else
          link_to(version.reify.name, version_path(version.item_id)) +
            " was deleted"
        end
      when "SpecialistSpecialization"
        if version.event == "create"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            " now specializes in " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            )
        elsif version.event == "update"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            "'s speciality in " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            ) +
            " was updated"
        else
          link_to(
            version.reify.specialist.name,
            specialist_path(version.reify.specialist)
          ) +
            " no longer specializes in " +
            link_to(
              version.reify.specialization.name,
              specialization_path(version.reify.specialization)
            )
        end
      when "SpecialistOffice"
        if version.event == "create"
          if version.item.office.present?
            link_to(
              version.item.specialist.name,
              specialist_path(version.item.specialist)
            ) +
              " now works in office " +
              link_to(
                version.item.office.short_address,
                office_path(version.item.office)
              )
          else
            ""
          end
        elsif version.event == "update"
          if version.item.office.present?
            link_to(
              version.item.specialist.name,
              specialist_path(version.item.specialist)
            ) +
              "'s office in " +
              link_to(
                version.item.office.short_address,
                office_path(version.item.office)
              ) +
              " was updated"
          else
            link_to(
              version.item.specialist.name,
              specialist_path(version.item.specialist)
            ) +
              "'s office was deleted"
          end
        else
          if version.reify.office.present?
            link_to(
              version.reify.specialist.name,
              specialist_path(version.reify.specialist)
            ) +
              " no longer works in office " +
              link_to(
                version.reify.office.short_address,
                office_path(version.reify.office)
              )
          else
            ""
          end
        end
      when "SpecialistAddress"
        ""
      when "Capacity"
        if version.event == "create"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            " now performs " +
            link_to(
              version.item.procedure.name,
              procedure_path(version.item.procedure)
            )
        elsif version.event == "update"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            "'s area of practice " +
            link_to(
              version.item.procedure.name,
              procedure_path(version.item.procedure)
            ) +
            " was updated"
        else
          link_to(
            version.reify.specialist.name,
            specialist_path(version.reify.specialist)
          ) +
            " no longer performs " +
            link_to(
              version.reify.procedure.name,
              procedure_path(version.reify.procedure)
            )
        end
      when "Attendance"
        if version.event == "create"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            " now works in " +
            link_to(version.item.clinic.name, clinic_path(version.item.clinic))
        elsif version.event == "update"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            "'s association with clinic " +
            link_to(
              version.item.clinic.name,
              clinic_path(version.item.clinic)
            ) +
            " was updated"
        else
          link_to(
            version.reify.specialist.name,
            version_path(version.reify.specialist)
          ) +
            " no longer works in " +
            link_to(
              version.reify.clinic.name,
              clinic_path(version.reify.clinic)
            )
        end
      when "SpecialistSpeak"
        if version.event == "create"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            "'s office now speaks " +
            link_to(
              version.item.language.name,
              language_path(version.item.language)
            )
        elsif version.event == "update"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            "'s office language " +
            link_to(
              version.item.language.name,
              language_path(version.item.language)
            ) +
            " was updated"
        else
          link_to(
            version.reify.specialist.name,
            specialist_path(version.reify.specialist)
          ) +
            "'s office no longer speaks " +
            link_to(
              version.item.language.name,
              language_path(version.item.language)
            )
        end
      when "Privilege"
        if version.event == "create"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            " now has hospital privileges at " +
            link_to(
              version.item.hospital.name,
              hospital_path(version.item.hospital)
            )
        elsif version.event == "update"
          link_to(
            version.item.specialist.name,
            specialist_path(version.item.specialist)
          ) +
            "'s hospital privileges at " +
            link_to(
              version.item.hospital.name,
              hospital_path(version.item.hospital)
            ) +
            " were updated"
        else
          link_to(
            version.reify.specialist.name,
            specialist_path(version.reify.specialist)
          ) +
            " no longer has hospital privileges at " +
            link_to(
              version.reify.hospital.name,
              hospital_path(version.reify.hospital)
            )
        end
      when "Clinic"
        if version.event == "create"
          link_to(version.item.name, clinic_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, clinic_path(version.item_id)) +
            " was updated"
        else
          link_to(version.reify.name, version_path(version.item_id)) +
            " was deleted"
        end
      when "ClinicLocation"
        if version.event == "create"
          if version.item.location.present?
            link_to(
              version.item.clinic.name,
              clinic_path(version.item.clinic)
            ) +
            " now works in " +
            version.item.location.short_address
          else
            ""
          end
        elsif version.event == "update"
          if version.item.location.present?
            link_to(
              version.item.clinic.name,
              clinic_path(version.item.clinic)
            ) +
            "'s location at " +
            version.item.location.short_address +
            " was updated"
          else
            link_to(
              version.item.clinic.name,
              clinic_path(version.item.clinic)
            ) +
            "'s office was deleted"
          end
        else
          if version.reify.location.present?
            link_to(
              version.reify.clinic.name,
              clinic_path(version.reify.clinic)
            ) +
            " no longer located at " +
            version.item.location.short_address
          else
            ""
          end
        end
      when "ClinicAddress"
        ""
      when "ClinicSpecialization"
        if version.event == "create"
          link_to(version.item.clinic.name, clinic_path(version.item.clinic)) +
            " now specializes in " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            )
        elsif version.event == "update"
          link_to(version.item.clinic.name, clinic_path(version.item.clinic)) +
            " speciality in " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            ) +
            " was updated"
        else
          link_to(
            version.reify.clinic.name,
            clinic_path(version.reify.clinic)
          ) +
            " no longer specializes in " +
            link_to(
              version.reify.specialization.name,
              specialization_path(version.reify.specialization)
            )
        end
      when "Focus"
        if version.event == "create"
          link_to(version.item.clinic.name, clinic_path(version.item.clinic)) +
            " now performs " +
            link_to(
              version.item.procedure.name,
              procedure_path(version.item.procedure)
            )
        elsif version.event == "update"
          link_to(version.item.clinic.name, clinic_path(version.item.clinic)) +
            " area of practice " +
            link_to(
              version.item.procedure.name,
              procedure_path(version.item.procedure)
            ) +
            " was updated"
        else
          link_to(
            version.reify.clinic.name,
            clinic_path(version.reify.clinic)
          ) +
            " no longer performs " +
            link_to(
              version.reify.procedure.name,
              procedure_path(version.reify.procedure)
            )
        end
      when "ClinicSpeak"
        if version.event == "create"
          link_to(version.item.clinic.name, clinic_path(version.item.clinic)) +
            "'s office now speaks " +
            link_to(
              version.item.language.name,
              language_path(version.item.language)
            )
        elsif version.event == "update"
          link_to(version.item.clinic.name, clinic_path(version.item.clinic)) +
            "'s office languages " +
            link_to(
              version.item.language.name,
              language_path(version.item_id)
            ) +
            " was updated"
        else
          link_to(
            version.reify.clinic.name,
            clinic_path(version.reify.clinic)
          ) +
            "'s office no longer speaks " +
            link_to(
              version.item.language.name,
              language_path(version.item_id)
            )
        end
      when "ClinicHealthcareProvider"
        if version.event == "create"
          link_to(
            version.item.clinic.name,
            clinic_path(version.item.clinic)
          ) +
            " now has healthcare provider " +
            link_to(
              version.item.healthcare_provider.name,
              healthcare_provider_path(version.item.healthcare_provider)
            )
        elsif version.event == "update"
          link_to(
            version.item.clinic.name,
            clinic_path(version.item.clinic)
          ) +
            "'s healthcare provider " +
            link_to(
              version.item.healthcare_provider.name,
              healthcare_provider_path(version.item_id)
            ) +
            " was updated"
        else
          link_to(
            version.reify.clinic.name,
            clinic_path(version.reify.clinic)
          ) +
            " no longer has healthcare provider " +
            link_to(
              version.reify.healthcare_provider.name,
              healthcare_provider_path(version.item_id)
            )
        end
      when "Hospital"
        if version.event == "create"
          link_to(version.item.name, hospital_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, hospital_path(version.item_id)) +
            " was updated"
        else
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
          link_to(version.item.name, procedure_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, procedure_path(version.item_id)) +
            " was updated"
        else
          link_to(version.reify.name, version_path(version.item_id)) +
            " was deleted"
        end
      when "ProcedureSpecialization"
        if version.event == "create"
          link_to(
            version.item.procedure.name,
            procedure_path(version.item.procedure)
          ) +
            " is now performed by " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            )
        elsif version.event == "update"
          link_to(
            version.item.procedure.name,
            procedure_path(version.item.procedure)
          ) +
            " specialty in " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            ) +
            " was updated"
        else
          link_to(
            version.reify.procedure.name,
            procedure_path(version.reify.procedure)
          ) +
            " is no longer performed by " +
            link_to(
              version.reify.specialization.name,
              specialization_path(version.reify.specialization)
            )
        end
      when "Language"
        if version.event == "create"
          link_to(version.item.name, language_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, language_path(version.item_id)) +
            " was updated"
        else
        end
      when "HealthcareProvider"
        if version.event == "create"
          link_to(
            version.item.name,
            healthcare_provider_path(version.item_id)
          ) +
            " was created"
        elsif version.event == "update"
          link_to(
            version.item.name,
            healthcare_provider_path(version.item_id)
          ) +
            " was updated"
        else
          link_to(version.reify.name, version_path(version.item_id)) +
            " was deleted"
        end
      when "Schedule"
        if version.event == "create" || version.event == "update"
          if version.item.days_and_hours.length == 0
            ""
          elsif version.item.schedulable.is_a? SpecialistOffice
            link_to(
              version.item.schedulable.specialist.name,
              url_for(version.item.schedulable.specialist)
            ) +
              " has the schedule: " +
              version.item.days_and_hours.to_sentence
          elsif version.item.schedulable.is_a? ClinicLocation
            link_to(
              version.item.schedulable.clinic.name,
              url_for(version.item.schedulable.clinic)
            ) +
              " has the schedule: " +
              version.item.days_and_hours.to_sentence
          else
            ""
          end
        else
          if version.reify.schedulable.is_a? SpecialistOffice
            link_to(
              version.item.schedulable.specialist.name,
              url_for(version.item.schedulable.specialist)
            ) +
              " no longer has a schedule"
          elsif version.reify.schedulable.is_a? ClinicLocation
            link_to(
              version.item.schedulable.clinic.name,
              url_for(version.item.schedulable.clinic)
            ) +
              " no longer has a schedule"
          else
            ""
          end
        end
      when "ScheduleDay"
        ""
      when "UserControlsClinicLocation"
        if version.event == "create" || version.event == "update"
          link_to(version.item.user.name, user_path(version.item.user)) +
            " has the ability to edit " +
            link_to(
              version.item.clinic_location.clinic.name,
              clinic_path(version.item.clinic_location.clinic)
            )
        else
          link_to(version.reify.user.name, user_path(version.reify.user)) +
            " no longer has the ability to edit " +
            link_to(
              version.reify.clinic_location.clinic.name,
              clinic_path(version.reify.clinic_location.clinic)
            )
        end
      when "UserControlsSpecialistOffice"
        if version.event == "create" || version.event == "update"
          link_to(version.item.user.name, user_path(version.item.user)) +
            " has the ability to edit " +
            link_to(
              version.item.specialist_office.specialist.name,
              specialist_path(version.item.specialist_office.specialist)
            )
        else
          link_to(version.reify.user.name, user_path(version.reify.user)) +
            " no longer has the ability to edit " +
            link_to(
              version.reify.specialist_office.specialist.name,
              specialist_path(version.reify.specialist_office.specialist)
            )
        end
      when "SpecializationOption"
        if version.event == "create" || version.event == "update"
          "The options for " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            ) +
            " in division " +
            link_to(
              version.item.division.name,
              division_path(version.item.division)
            ) +
            " have changed"
        end
      when "Division"
        if version.event == "create"
          link_to(version.item.name, division_path(version.item_id)) +
            " was created"
        elsif version.event == "update"
          link_to(version.item.name, division_path(version.item_id)) +
            " was updated"
        else
          link_to(version.reify.name, show_division_path(version.item_id)) +
            " was deleted"
        end
      when "DivisionUser"
        if version.event == "create" || version.event == "update"
          link_to(version.item.user.name, user_path(version.item.user)) +
            " is now a member of " +
            link_to(
              version.item.division.name,
              division_path(version.item.division)
            )
        else
          link_to(version.reify.user.name, user_path(version.reify.user)) +
            " is no longer a member of " +
            link_to(
              version.reify.division.name,
              division_path(version.reify.division)
            )
        end
      when "DivisionDisplayScItem"
        if version.event == "create" || version.event == "update"
          link_to(
            version.item.division.name,
            division_path(version.item.division)
          ) +
            " is now borrowing the content item " +
            link_to(
              version.item.sc_item.title,
              sc_item_path(version.item.sc_item)
            )
        else
          link_to(
            version.reify.division.name,
            division_path(version.reify.division)
          ) +
            " is no longer borrowing the content item " +
            link_to(
              version.reify.sc_item.title,
              sc_item_path(version.reify.sc_item)
            )
        end
      when "DivisionReferralCitySpecialization"
        if version.event == "create" || version.event == "update"
          link_to(
            version.item.division_referral_city.division.name,
            division_path(version.item.division_referral_city.division)
          ) +
            " now has " +
            version.item.division_referral_city.city.name +
            " in their local referral area for " +
            link_to(
              version.item.specialization.name,
              specialization_path(version.item.specialization)
            )
        end
      when "DivisionReferralCity"
        ""
      when "DivisionCity"
        if version.event == "create" || version.event == "update"
          link_to(
            version.item.division.name,
            division_path(version.item.division)
          ) +
            " now owns " +
            version.item.city.name
        end
      when "ReferralForm"
        ""
      when "Secret Token"
        ""
      else
        "#{version.item_type}"
    end
    rescue Exception => exc
      "This item (" +
      (
        if version.reify.respond_to?('name')
          version.reify.name + ', ' + version.item_type
        else
          version.item_type
        end
      ) +
      ") was deleted after the change was made"
  end

  def translate_changes(version, attribute, changeset)
    return 'Yes' if changeset == true
    return 'No' if changeset == false
    begin
      I18n.translate(
        "#{version.item_type.constantize.i18n_scope}.values."\
          "#{version.item_type.constantize.model_name.i18n_key}."\
          "#{attribute}.#{changeset}",
        raise: I18n::MissingTranslationData
      )
    rescue I18n::MissingTranslationData
      changeset
    end
  end
end
