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

  def tagged_specialization_options
    Specialization.
      order(:name).
      where("specializations.member_tag IS NOT NULL AND specializations.member_tag != ''").
      map{|s| [ s.id, s.member_tag ]}.
      sort_by(&:second).
      unshift([nil, "Not Specified"])
  end

  def specialist_specializations_listing(specialist)
    listing = ""

    if specialist.is_gp?
      listing += "GP "

      if specialist.specializations.any?
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
    if section_key == :practice_details
      specialist.practice_details.present? && (
        specialist.practicing? ||
          specialist.is_deceased? ||
          specialist.went_on_leave?
      )
    else
      case section_key
      when :basic_associations
        !show_specialist_section?(specialist, :expanded_associations) &&
          (specialist.open_clinics.any? || specialist.hospitals.any?)
      when :expanded_associations
        !specialist.works_from_offices? &&
          (specialist.open_clinics.any? || specialist.hospitals.any?)
      when :office_information
        specialist.non_empty_offices.any? ||
          specialist.languages.any? ||
          specialist.interpreter_available
      when :ongoing_care
        specialist.works_from_offices &&
          specialist.indirect_referrals_only? &&
          specialist.specialist_offices.select(&:has_data?).any?
      when :patient_information
        specialist.patient_instructions.present? ||
          specialist.cancellation_policy.present?
      when :referrals
        specialist.accepting_new_direct_referrals? &&
          (specialist.accepts_referrals_via.present? ||
            specialist.responds_via.present? ||
            specialist.referral_form_mask != 3 ||
            specialist.required_investigations.present? ||
            specialist.waittime.present? ||
            specialist.lagtime.present? ||
            specialist.patient_can_book_mask != 3)
      when :sidebar
        true
      when :teleservices
        !specialist.teleservices_require_review &&
          specialist.teleservices.any?(&:offered?)
      when :urgent_referrals
        specialist.accepting_new_direct_referrals? &&
          (specialist.red_flags.present? ||
            specialist.urgent_referrals_via.present?)
      end && (specialist.practicing? || specialist.went_on_leave?)
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
