module GenerateClinicFocusInputs

  def self.exec(clinic)
    focus_inputs = []

    # So we don't duplicate procedures
    procedures_covered = []

    clinic.specializations.inject({}) do |memo, specialization|
      memo.merge(specialization.non_assumed_procedure_specializations_arranged)
    end.each do |ps, children|
      if !procedures_covered.include?(ps.procedure.id)
        focus_inputs << generate_focus(clinic, ps, 0)
        procedures_covered << ps.procedure.id
      end
      children.each do |child_ps, grandchildren|
        if !procedures_covered.include?(child_ps.procedure.id)
          focus_inputs << generate_focus(clinic, child_ps, 1)
          procedures_covered << child_ps.procedure.id
        end
        grandchildren.each do |grandchild_ps, greatgrandchildren|
          if !procedures_covered.include?(grandchild_ps.procedure.id)
            focus_inputs << generate_focus(clinic, grandchild_ps, 2)
            procedures_covered << grandchild_ps.procedure.id
          end
        end
      end
    end

    focus_inputs
  end

  def self.generate_focus(clinic, procedure_specialization, offset)
    if clinic.present?
      focus = Focus.find_by_clinic_id_and_procedure_specialization_id(
        clinic.id,
        procedure_specialization.id
      )
    else
      focus = nil
    end

    {
      :mapped => focus.present?,
      :name => procedure_specialization.procedure.name,
      :id => procedure_specialization.id,
      :investigations => focus.present? ? focus.investigation : "",
      :custom_wait_time => procedure_specialization.clinic_wait_time?,
      :waittime => focus.present? ? focus.waittime_mask : 0,
      :lagtime => focus.present? ? focus.lagtime_mask : 0,
      :offset => offset
    }
  end
end
