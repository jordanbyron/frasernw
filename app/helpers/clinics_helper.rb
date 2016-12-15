module ClinicsHelper
  def specialists_who_work_in(clinic)
    clinic.specialists.map do |specialist|
      if specialist.hidden?
        specialist.name
      else
        link_to(specialist.name, specialist_path(specialist))
      end
    end.to_sentence
  end

  def physician_attending(attendance)
    content_tag :li do
      if attendance.specialist.hidden?
        attendance.specialist.name
      else

        content = link_to(
          attendance.specialist.name,
          specialist_path(attendance.specialist)
        )

        if attendance.specialist.padded_billing_number.present?
          content += " - MSP ##{attendance.specialist.padded_billing_number}"
        end

        if attendance.area_of_focus.present?
          content += " - #{attendance.area_of_focus}"
        end

        content
      end
    end
  end

  def clinic_specializations_listing(clinic)
    clinic.specializations.map do |specialization|
      link_to specialization.name, specialization_path(specialization)
    end.to_sentence
  end

  def show_clinic_section?(clinic, section_key)
    case section_key
    when :clinic_information
      clinic.clinic_locations.select(&:has_data?).any? ||
        clinic.languages.any? ||
        clinic.interpreter_available
    when :healthcare_providers
      clinic.healthcare_providers.present?
    when :patient_information
      clinic.patient_instructions.present? ||
        clinic.cancellation_policy.present?
    when :physicians
      clinic.visible_attendances.any?
    when :referrals
      clinic.accepts_referrals_via.present? ||
        clinic.responds_via.present? ||
        clinic.referral_form_mask != 3  ||
        clinic.required_investigations.present? ||
        clinic.waittime.present? ||
        clinic.lagtime.present? ||
        clinic.patient_can_book_mask != 3
    when :sidebar
      true
    when :teleservices
      !clinic.teleservices_require_review &&
        clinic.teleservices.any?(&:offered?)
    when :urgent_referrals
      clinic.red_flags.present? || clinic.urgent_referrals_via.present?
    end && clinic.open?
  end
end
