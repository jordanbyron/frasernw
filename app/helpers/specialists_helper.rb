module SpecialistsHelper
  def clinic_associations(clinics)
    clinics.uniq.map do |clinic|
      if clinic.hidden?
        clinic.name
      else
        link_to(clinic.name, clinic_path(clinic))
      end
    end.to_sentence
  end

  def specialist_specializations_listing(specialist)
    listing = ""

    if specialist.is_gp?
      listing += "GP "

      if specialist.specializations.many?
        listing += "with a focus in "
      end
    end

    listing += specialist.specializations.not_family_practice.map do |specialization|
      link_to(
        specialization.name,
        specialization_path(specialization)
      )
    end.to_sentence

    listing
  end

  def show_specialist_section?(specialist, section_key)
    case section_key
    when :office_information
      (specialist.practicing? || specialist.went_on_leave?) &&
        (specialist.non_empty_offices.any? ||
          specialist.languages.any? ||
          specialist.interpreter_available)
    when :referrals
      (specialist.practicing? || specialist.went_on_leave?) &&
      specialist.accepting_new_direct_referrals? &&
        (specialist.accepts_referrals_via.present? ||
          specialist.responds_via.present? ||
          specialist.referral_form_mask != 3 ||
          specialist.required_investigations.present? ||
          specialist.waittime.present? ||
          specialist.lagtime.present? ||
          specialist.patient_can_book_mask != 3)
    when :urgent_referrals
      (specialist.practicing? || specialist.went_on_leave?) &&
      specialist.accepting_new_direct_referrals? &&
        (specialist.red_flags.present? ||
          specialist.urgent_referrals_via.present?)
    when :basic_associations
      (specialist.practicing? || specialist.went_on_leave?) &&
        !show_specialist_section?(specialist, :expanded_associations) &&
        (specialist.open_clinics.any? ||
          specialist.hospitals.any?)
    when :expanded_associations
      (specialist.practicing? || specialist.went_on_leave?) &&
        !specialist.works_from_offices?
    when :practice_details
      (specialist.practicing? || specialist.is_deceased? || specialist.went_on_leave?) &&
        specialist.practice_details.present?
    when :patient_information
      (specialist.practicing? || specialist.went_on_leave?) &&
        (specialist.patient_instructions.present? ||
          specialist.cancellation_policy.present?)
    when :ongoing_care
      (specialist.practicing? || specialist.went_on_leave?) &&
        specialist.works_from_offices &&
        specialist.indirect_referrals_only? &&
        specialist.specialist_offices.select(&:has_data?).any?
    when :teleservices
      specialist.practicing? &&
        !specialist.teleservices_require_review &&
        specialist.teleservices.any?(&:offered?)
    end
  end

  def specialization_checked?(specialization, specialist, params)
    specialization.id == params[:specialization_id].to_i ||
      specialist.specializations.include?(specialization)
  end

  def show_accepts_indirect_referrals?(specialist)
    specialist.specialist_specializations.find do |specialist_specialization|
      specialist_specialization.specialization_id ==
        Specialization.find_by(name: "Family Practice").id
    end
  end
end
