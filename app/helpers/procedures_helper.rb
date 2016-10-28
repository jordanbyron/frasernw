module ProceduresHelper

  def procedure_ancestry_options_limited(items, skip_tree, &block)
    return procedure_ancestry_options_limited(items, skip_tree) do |i|
      "#{'-' * i.depth} #{i.procedure.name}"
    end unless block_given?

    result = []
    items.map do |item, sub_items|
      next if skip_tree and skip_tree.include? item
      next if not item.procedure
      result << [yield(item), item.id]
      result += procedure_ancestry_options_limited(sub_items, skip_tree, &block)
    end
    result
  end

  def nested_procedure_checkboxes(target, nested_procedure_specializations, level = 0)
    nested_procedure_specializations.each do |procedure_specialization, children|
      content_tag :label do
        check_box_tag(
          "#{form_target_type(target)}[procedure_ids][]",
          procedure_specialization.procedure.id,
          target.procedures.include?(procedure_specialization.procedure),
          id: "#{form_target_type(target)}[procedure_ids][]"
          class: "offset#{level + 1}"
        ) + content_tag(:span, procedure_specialization.procedure.name)
      end + nested_procedure_checkboxes(form_target_type(target), children, (level + 1))
    end
  end


  def procedure_classification_options(procedure_specialization)
    [
      [
        ProcedureSpecialization::CLASSIFICATION_HASH[ProcedureSpecialization::CLASSIFICATION_FOCUSED],
        ProcedureSpecialization::CLASSIFICATION_FOCUSED
      ],
      [
        ProcedureSpecialization::CLASSIFICATION_HASH[ProcedureSpecialization::CLASSIFICATION_NONFOCUSED],
        ProcedureSpecialization::CLASSIFICATION_NONFOCUSED
      ],
      [
        ProcedureSpecialization::CLASSIFICATION_HASH[ProcedureSpecialization::CLASSIFICATION_ASSUMED_SPECIALIST],
        ProcedureSpecialization::CLASSIFICATION_ASSUMED_SPECIALIST
      ],
      [
        ProcedureSpecialization::CLASSIFICATION_HASH[ProcedureSpecialization::CLASSIFICATION_ASSUMED_CLINIC],
        ProcedureSpecialization::CLASSIFICATION_ASSUMED_CLINIC
      ],
      [
        ProcedureSpecialization::CLASSIFICATION_HASH[ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH],
        ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH
      ]
    ]
  end

  def procedure_ancestry_options(procedure_specialization)
    [["~ No parent ~", nil]] +
      procedure_ancestry_options_limited(
        procedure_specialization.specialization.arranged_procedure_specializations,
        (procedure_specialization.new_record? ? [] : procedure_specialization.subtree)
      )
  end

  def procedure_specialization_checked(params, procedure_specialization)
    procedure_specialization.specialization.id.to_s == params[:specialization_id] ||
      !procedure_specialization.new_record?
  end
end
