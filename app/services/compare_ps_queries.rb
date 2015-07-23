module ComparePsQueries
  def self.exec
    Specialization.all.each do |specialization|
      puts "Specialization #{specialization.name}"
      compare_query_results(specialization)
    end
  end

  def self.compare_query_results(specialization)
    compare_hashes(
      specialization.focused_procedure_specializations_arranged,
      specialization.arranged_procedure_specializations(:focused)
    )

    compare_hashes(
      specialization.non_focused_procedure_specializations_arranged,
      specialization.arranged_procedure_specializations(:non_focused)
    )

    compare_hashes(
      specialization.assumed_clinic_procedure_specializations_arranged,
      specialization.arranged_procedure_specializations(:assumed_clinic)
    )

    compare_hashes(
      specialization.assumed_specialist_procedure_specializations_arranged,
      specialization.arranged_procedure_specializations(:assumed_specialist)
    )

    compare_hashes(
      specialization.non_assumed_procedure_specializations_arranged,
      specialization.arranged_procedure_specializations(:non_assumed)
    )

    compare_hashes(
      specialization.procedure_specializations_arranged,
      specialization.arranged_procedure_specializations
    )
  end

  def self.compare_hashes(hsh1, hsh2, level = 1)
    hsh1.each_with_index do |(hsh1_key, hsh1_val), index|
      puts "LEVEL #{level}"
      hsh2_key = hsh2.keys[index]
      hsh2_val = hsh2[hsh2_key]

      # check keys
      raise if !(hsh1_key.is_a?(ProcedureSpecialization))
      raise if !(hsh2_key.is_a?(ProcedureSpecialization))
      raise if hsh1_key.id != hsh2_key.id

      # check values
      if hsh1_val.is_a?(Hash) && hsh2_val.is_a?(Hash)
        compare_hashes(hsh1_val, hsh2_val, (level + 1))
      elsif hsh1_val.is_a?(ProcedureSpecialization) && hsh2_val.is_a?(ProcedureSpecialization)
        raise if hsh1_val.id != hsh2_val.id
      else
        raise
      end
    end
  end
end
