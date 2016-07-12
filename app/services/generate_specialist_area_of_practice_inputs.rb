class GenerateSpecialistAreaOfPracticeInputs
  attr_reader :specialist, :specializations

  def self.exec(specialist, specializations)
    new(specialist, specializations).exec
  end

  def initialize(specialist, specializations)
    @specialist = specialist
    @specializations = specializations
  end

  def exec
    specialist_area_of_practice_inputs = []

    # so we don't duplicate procedures
    procedures_covered = []

    specializations.inject({}) do |memo, specialization|
      memo.merge(
        specialization.arranged_procedure_specializations(:non_assumed)
      )
    end.each do |ps, children|
      if !procedures_covered.include?(ps.procedure.id)
        specialist_area_of_practice_inputs << generate_specialist_area_of_practice(specialist, ps, 0)
        procedures_covered << ps.procedure.id
      end
      children.each do |child_ps, grandchildren|
        if !procedures_covered.include?(child_ps.procedure.id)
          specialist_area_of_practice_inputs << generate_specialist_area_of_practice(specialist, child_ps, 1)
          procedures_covered << child_ps.procedure.id
        end
        grandchildren.each do |grandchild_ps, greatgrandchildren|
          if !procedures_covered.include?(grandchild_ps.procedure.id)
            specialist_area_of_practice_inputs << generate_specialist_area_of_practice(specialist, grandchild_ps, 2)
            procedures_covered << grandchild_ps.procedure.id
          end
        end
      end
    end


    specializations.map do |specialization|
      {
        specialization_name: specialization.name,
        specialist_areas_of_practice: specialist_area_of_practice_inputs.select{ |input|
          input[:specialization_id] == specialization.id
        }
      }
    end
  end

  def specialist_areas_of_practice
    @specialist_areas_of_practice ||= begin
      if specialist.present?
        specialist.specialist_areas_of_practice
      else
        []
      end
    end
  end

  def generate_specialist_area_of_practice(specialist, procedure_specialization, offset)
    specialist_area_of_practice = specialist_areas_of_practice.find do |specialist_area_of_practice|
      specialist_area_of_practice.procedure_specialization_id == procedure_specialization.id
    end

    {
      mapped: specialist_area_of_practice.present?,
      name: procedure_specialization.procedure.name,
      specialization_id: procedure_specialization.specialization_id,
      id: procedure_specialization.id,
      investigations: specialist_area_of_practice.present? ? specialist_area_of_practice.investigation : "",
      custom_wait_time: procedure_specialization.specialist_wait_time?,
      waittime: specialist_area_of_practice.present? ? specialist_area_of_practice.waittime_mask : 0,
      lagtime: specialist_area_of_practice.present? ? specialist_area_of_practice.lagtime_mask : 0,
      offset: offset
    }
  end
end
