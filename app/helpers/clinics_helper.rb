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

  def physician_attending(clinic_specialist)
    content_tag :li do
      if clinic_specialist.specialist.hidden?
        clinic_specialist.specialist.name
      else
        content = link_to(
          clinic_specialist.specialist.name,
          specialist_path(clinic_specialist.specialist)
        )

        if clinic_specialist.specialist.padded_billing_number.present?
          content += " - MSP ##{clinic_specialist.specialist.padded_billing_number}"
        end

        if clinic_specialist.area_of_focus.present?
          content += " - #{clinic_specialist.area_of_focus}"
        end

        content
      end
    end
  end
end
