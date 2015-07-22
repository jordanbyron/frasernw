module GenerateSpecialistCapacityInputs
  def self.exec(specialist)
    procedures_covered = []
    capacities = []

    specialist.specializations.inject({}) do |memo, specialization|
      memo.merge(specialization.non_assumed_procedure_specializations_arranged)
    end.each do |ps, children|
      if !procedures_covered.include?(ps.procedure.id)
        capacities << generate_capacity(specialist, ps, 0)
        procedures_covered << ps.procedure.id
      end
      children.each do |child_ps, grandchildren|
        if !procedures_covered.include?(child_ps.procedure.id)
          capacities << generate_capacity(specialist, child_ps, 1)
          procedures_covered << child_ps.procedure.id
        end
        grandchildren.each do |grandchild_ps, greatgrandchildren|
          if !procedures_covered.include?(grandchild_ps.procedure.id)
            capacities << generate_capacity(specialist, grandchild_ps, 2)
            procedures_covered << grandchild_ps.procedure.id
          end
        end
      end
    end

    capacities
  end

  def self.generate_capacity(specialist, procedure_specialization, offset)
    if specialist.present?
      capacity = Capacity.find_by_specialist_id_and_procedure_specialization_id(
        specialist.id,
        procedure_specialization.id
      )
    else
      capacity = nil
    end

    {
      :mapped => capacity.present?,
      :name => procedure_specialization.procedure.name,
      :id => procedure_specialization.id,
      :investigations => capacity.present? ? capacity.investigation : "",
      :custom_wait_time => procedure_specialization.specialist_wait_time?,
      :waittime => capacity.present? ? capacity.waittime_mask : 0,
      :lagtime => capacity.present? ? capacity.lagtime_mask : 0,
      :offset => offset
    }
  end
end
