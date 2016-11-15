module ProceduresHelper

  def procedures_listing(nested_procedures, linked_item, depth = 0)
    content_tag(:ul) do
      nested_procedures.inject("") do |memo, (procedure, children)|
        memo += content_tag(:li) do
          tag_type = depth == 0 ? :strong : :span

          contents = content_tag(tag_type) do
            link_to(procedure.name_relative_to_parents, procedure)
          end

          _investigation = item.
            procedure_links.
            find_by(procedure_id: procedure.id).
            investigation.strip.strip_period
          if _investigation.present?
            memo += content_tag(:span) do
              " (#{_investigation})"
            end
          end

          if children.any?
            memo += content_tag(:span, ": ")
            memo += procedures_listing(children, linked_item, depth + 1)
          end
        end
      end
    end
  end

  def nested_procedure_checkboxes(target, parent_node, nested_procedure_specializations, level = 0)
    @procedure_checkboxes_rendered ||= {}
    nested_procedure_specializations.inject("") do |memo, (procedure_specialization, children)|
      # we only want to send one set of params per procedure,
      # even though there will be multiple checkboxes per procedure
      # (js should ensure that inputs with matching procedures mirror each other)

      if @procedure_checkboxes_rendered.has_key?(procedure_specialization.procedure_id)
        param_set_number = @procedure_checkboxes_rendered[(procedure_specialization.procedure_id)]
      else
        param_set_number = @procedure_checkboxes_rendered.length + 1
        @procedure_checkboxes_rendered[procedure_specialization.procedure_id] = param_set_number
      end

      _input_name_root = form_target_type(target) +
        "[#{form_target_type(target)}_procedures][#{param_set_number}]"

      memo + content_tag(
        :label,
        class: "ps-tree-node-container",
        "data-ps-tree-parent" => "#{parent_node.class.to_s}#{parent_node.id}",
        "data-procedure-id" => procedure_specialization.procedure_id
      ) do
        returning = hidden_field_tag(
          "#{_input_name_root}[procedure_id]",
          procedure_specialization.procedure_id
        ) + hidden_field_tag(
          "#{_input_name_root}[_destroy]",
          "1"
        ) + check_box_tag(
          "#{_input_name_root}[_destroy]",
          "0",
          target.procedures.include?(procedure_specialization.procedure),
          class: "offset#{level + 1} ps-tree-node-input",
          "data-ps-tree-id" => "ProcedureSpecialization#{procedure_specialization.id}",
          "data-procedure-id" => procedure_specialization.procedure_id
        ) + content_tag(
          :span,
          procedure_specialization.procedure.name,
          style: "margin-left: 5px"
        )

        if target.procedures.include?(procedure_specialization.procedure)
          returning += hidden_field_tag(
            "#{_input_name_root}[id]",
            target.procedure_links.find_by(procedure_id: procedure_specialization.procedure_id).id
          )
        end

        returning
      end + nested_procedure_checkboxes(target, procedure_specialization, children, (level + 1))
    end.html_safe
  end

  def procedure_specialization_checked?(params, procedure_specialization)
    procedure_specialization.specialization.id.to_s == params[:specialization_id] ||
      !procedure_specialization.new_record?
  end
end
