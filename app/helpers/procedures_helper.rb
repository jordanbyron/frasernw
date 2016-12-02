module ProceduresHelper

  def procedure_specializable_form(procedure_specializable)
    react_component(
      "ProcedureSpecializableForm",
      {
        hierarchy: Specialization.procedure_hierarchy(
          procedure_specializable.class
        ),
        specialization_links: Specialization.all.map do |specialization|
            existing_link = procedure_specializable.
              specialization_links.
              find{|link| link.specialization_id == specialization.id }

            link =
              if existing_link.nil?
                {
                  specialization_id: specialization.id,
                  checked: false
                }
              else
                existing_link.attributes.merge(checked: true)
              end

            [ specialization.id, link ]
          end.to_h,
        procedure_links: Procedure.all.map do |procedure|
            existing_link = procedure_specializable.
              procedure_links.
              find{|link| link.procedure_id == procedure.id }

            link =
              if existing_link.nil?
                {
                  procedure_id: procedure.id,
                  checked: false
                }
              else
                existing_link.attributes.merge(checked: true)
              end

            [ procedure.id, link ]
          end.to_h,
        procedure_specializable_type: procedure_specializable.class.to_s.tableize.singularize,
        booking_wait_time_options: HasWaitTimes::BOOKING_WAIT_TIMES,
        consultation_wait_time_options: HasWaitTimes::CONSULTATION_WAIT_TIMES
      }
    )
  end

  def procedures_listing(nested_procedures, linked_item, depth = 0)

    content_tag(:ul, class: "procedures-listing-depth-#{depth}") do
      nested_procedures.
        to_a.
        sort_by{|pair| pair[0].name_relative_to_parents }.
        to_h.
        inject("".html_safe) do |memo, (procedure, children)|

        memo + content_tag(:li) do
          tag_type = depth == 0 ? :strong : :span

          contents = content_tag(tag_type) do
            link_to(procedure.name_relative_to_parents, procedure)
          end

          _investigation = linked_item.
            procedure_links.
            find_by(procedure_id: procedure.id).
            investigation.
            try(:strip).
            try(:strip_period)
          if _investigation.present?
            contents += content_tag(:span) do
              " (#{_investigation})"
            end
          end

          if children.any?
            contents += procedures_listing(children, linked_item, depth + 1)
          end

          contents
        end
      end
    end.html_safe
  end
end
