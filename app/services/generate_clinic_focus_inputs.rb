class GenerateClinicFocusInputs
  attr_reader :clinic, :specializations

  def self.exec(clinic, specializations)
    new(clinic, specializations).exec
  end

  def initialize(clinic, specializations)
    @clinic = clinic
    @specializations = specializations
  end

  def exec
    focus_inputs = []

    # So we don't duplicate procedures
    procedures_covered = []

    specializations.inject({}) do |memo, specialization|
      memo.merge(
        specialization.arranged_procedure_specializations(:non_assumed)
      )
    end.each do |ps, children|
      if !procedures_covered.include?(ps.procedure_id)
        focus_inputs << generate_focus(ps, 0)
        procedures_covered << ps.procedure_id
      end
      children.each do |child_ps, grandchildren|
        if !procedures_covered.include?(child_ps.procedure_id)
          focus_inputs << generate_focus(child_ps, 1)
          procedures_covered << child_ps.procedure_id
        end
        grandchildren.each do |grandchild_ps, greatgrandchildren|
          if !procedures_covered.include?(grandchild_ps.procedure_id)
            focus_inputs << generate_focus(grandchild_ps, 2)
            procedures_covered << grandchild_ps.procedure_id
          end
        end
      end
    end

    specializations.map do |specialization|
      {
        specialization_name: specialization.name,
        focuses: focus_inputs.select do |input|
          input[:specialization_id] == specialization.id
        end
      }
    end
  end

  def clinic_focuses
    @clinic_focuses ||= begin
      if clinic.present?
        clinic.focuses
      else
        []
      end
    end
  end

  def generate_focus(procedure_specialization, offset)
    focus = clinic_focuses.find do |focus|
      focus.procedure_id == procedure_specialization.procedure_id
    end

    {
      mapped: focus.present?,
      name: procedure_specialization.procedure.name,
      id: procedure_specialization.procedure_id,
      specialization_id: procedure_specialization.specialization_id,
      investigations: focus.present? ? focus.investigation : "",
      custom_wait_time: procedure_specialization.procedure.clinic_has_wait_time?,
      waittime: focus.present? ? focus.waittime_mask : 0,
      lagtime: focus.present? ? focus.lagtime_mask : 0,
      offset: offset
    }
  end
end
