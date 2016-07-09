class GenerateClinicAreaOfPracticeInputs
  attr_reader :clinic, :specializations

  def self.exec(clinic, specializations)
    new(clinic, specializations).exec
  end

  def initialize(clinic, specializations)
    @clinic = clinic
    @specializations = specializations
  end

  def exec
    clinic_area_of_practice_inputs = []

    # So we don't duplicate procedures
    procedures_covered = []

    specializations.inject({}) do |memo, specialization|
      memo.merge(
        specialization.arranged_procedure_specializations(:non_assumed)
      )
    end.each do |ps, children|
      if !procedures_covered.include?(ps.procedure.id)
        clinic_area_of_practice_inputs << generate_clinic_area_of_practice(ps, 0)
        procedures_covered << ps.procedure.id
      end
      children.each do |child_ps, grandchildren|
        if !procedures_covered.include?(child_ps.procedure.id)
          clinic_area_of_practice_inputs << generate_clinic_area_of_practice(child_ps, 1)
          procedures_covered << child_ps.procedure.id
        end
        grandchildren.each do |grandchild_ps, greatgrandchildren|
          if !procedures_covered.include?(grandchild_ps.procedure.id)
            clinic_area_of_practice_inputs << generate_clinic_area_of_practice(grandchild_ps, 2)
            procedures_covered << grandchild_ps.procedure.id
          end
        end
      end
    end

    specializations.map do |specialization|
      {
        specialization_name: specialization.name,
        clinic_areas_of_practice: clinic_area_of_practice_inputs.select{ |input|
          input[:specialization_id] == specialization.id
        }
      }
    end
  end

  def clinic_aops
    @clinic_aops ||= begin
      if clinic.present?
        clinic.clinic_areas_of_practice
      else
        []
      end
    end
  end

  def generate_clinic_area_of_practice(procedure_specialization, offset)
    clinic_area_of_practice = clinic_aops.find do |clinic_area_of_practice|
      clinic_area_of_practice.procedure_specialization_id == procedure_specialization.id
    end

    {
      :mapped => clinic_area_of_practice.present?,
      :name => procedure_specialization.procedure.name,
      :id => procedure_specialization.id,
      :specialization_id => procedure_specialization.specialization_id,
      :investigations => clinic_area_of_practice.present? ? clinic_area_of_practice.investigation : "",
      :custom_wait_time => procedure_specialization.clinic_wait_time?,
      :waittime => clinic_area_of_practice.present? ? clinic_area_of_practice.waittime_mask : 0,
      :lagtime => clinic_area_of_practice.present? ? clinic_area_of_practice.lagtime_mask : 0,
      :offset => offset
    }
  end
end
