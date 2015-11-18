class AddParentProcedureSpecialization
  include ServiceObjectModule.exec_with_args(:klasses, :hierarchy)

  def exec
    klasses.each do |klass|
      exec_for_klass(klass)
    end
  end

  def exec_for_klass(klass)
    klass.with_ps_with_ancestry(hierarchy).each do |record|
      parent_to_add = record.procedure_specializations.find do |ps|
        ps.matches_ancestry?(hierarchy)
      end.parent

      record.procedure_specialize_in!(parent_to_add.id)
    end
  end
end
