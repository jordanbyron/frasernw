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
end
