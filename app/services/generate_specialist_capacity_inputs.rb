class GenerateSpecialistCapacityInputs
  attr_reader :specialist, :specializations

  def self.exec(specialist, specializations)
    new(specialist, specializations).exec
  end

  def initialize(specialist, specializations)
    @specialist = specialist
    @specializations = specializations
  end

  def exec
    capacity_inputs = []

    # so we don't duplicate procedures
    procedures_covered = []

    specializations.inject({}) do |memo, specialization|
      memo.merge(
        specialization.arranged_procedure_specializations(:non_assumed)
      )
    end.each do |ps, children|
      if !procedures_covered.include?(ps.procedure.id)
        capacity_inputs << generate_capacity(specialist, ps, 0)
        procedures_covered << ps.procedure.id
      end
      children.each do |child_ps, grandchildren|
        if !procedures_covered.include?(child_ps.procedure.id)
          capacity_inputs << generate_capacity(specialist, child_ps, 1)
          procedures_covered << child_ps.procedure.id
        end
        grandchildren.each do |grandchild_ps, greatgrandchildren|
          if !procedures_covered.include?(grandchild_ps.procedure.id)
            capacity_inputs << generate_capacity(specialist, grandchild_ps, 2)
            procedures_covered << grandchild_ps.procedure.id
          end
        end
      end
    end


    specializations.map do |specialization|
      {
        specialization_name: specialization.name,
        capacities: capacity_inputs.select{ |input|
          input[:specialization_id] == specialization.id
        }
      }
    end
  end

  def specialist_capacities
    @specialist_capacities ||= begin
      if specialist.present?
        specialist.capacities
      else
        []
      end
    end
  end

  def generate_capacity(specialist, procedure_specialization, offset)
    capacity = specialist_capacities.find do |capacity|
      capacity.procedure_specialization_id == procedure_specialization.id
    end

    {
      mapped: capacity.present?,
      name: procedure_specialization.procedure.name,
      specialization_id: procedure_specialization.specialization_id,
      id: procedure_specialization.id,
      investigations: capacity.present? ? capacity.investigation : "",
      custom_wait_time: procedure_specialization.specialist_wait_time?,
      waittime: capacity.present? ? capacity.waittime_mask : 0,
      lagtime: capacity.present? ? capacity.lagtime_mask : 0,
      offset: offset
    }
  end
end
