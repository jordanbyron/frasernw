module ProceduresHelper

  def nested_procedure_checkboxes(target, nested_procedure_specializations, level = 0)
    nested_procedure_specializations.each do |procedure_specialization, children|
      content_tag(:label) do
        check_box_tag(
          "#{form_target_type(target)}[procedure_ids][]",
          procedure_specialization.procedure.id,
          target.procedures.include?(procedure_specialization.procedure),
          id: "#{form_target_type(target)}[procedure_ids][]",
          class: "offset#{level + 1}"
        ) + content_tag(:span, procedure_specialization.procedure.name)
      end + nested_procedure_checkboxes(form_target_type(target), children, (level + 1))
    end
  end

  def procedure_specialization_checked?(params, procedure_specialization)
    procedure_specialization.specialization.id.to_s == params[:specialization_id] ||
      !procedure_specialization.new_record?
  end
end
