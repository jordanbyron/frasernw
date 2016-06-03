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
end
