class EnforceProcedureHierarchy < ServiceObject
  attribute :procedure

  def call
    procedure.linked_items.each do |linked|
      enforce_own_specializations(linked)
      enforce_ancestry(linked)
    end
  end

  def enforce_own_specializations(linked)
    if !linked.specializations.include?(procedure.specializations)
      linked.procedure_links.find_by(procedure_id: procedure.id).destroy
    end
  end

  def enforce_ancestry(linked)
    procedure_specialization_ancestors.
      select do |procedure_specialization|
        linked.specializations.include?(procedure_specialization.specialization) &&
          !linked.procedures.include?(procedure_specialization.procedure) &&
          !procedure_specialization.assumed_for_klass?(linked.class)
      end.map(&:procedure).
      uniq.
      each do |procedure|
        linked.procedure_links.create(procedure_id: procedure.id)
      end
  end

  def procedure_specialization_ancestors
    @procedure_specialization_ancestors ||= procedure.
      procedure_specializations.
      map(&:ancestors).
      flatten
  end

end
