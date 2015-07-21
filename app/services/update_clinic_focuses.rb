module UpdateClinicFocuses
  def self.exec(clinic, params)
    return unless params[:focuses_mapped].present?

    clinic.focuses.each do |focus|
      focus_checkbox_key = focus.procedure_specialization.id.to_s
      if params[:focuses_mapped][focus_checkbox_key] == "0"
        focus.destroy
      end
    end

    clinic_specializations = clinic.specializations
    params[:focuses_mapped].select do |checkbox_key, value|
      value == "1"
    end.each do |checkbox_key, value|
      focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(
        clinic.id,
        checkbox_key
      )
      focus.investigation = params[:focuses_investigations][checkbox_key]
      focus.waittime_mask = params[:focuses_waittime][checkbox_key] if params[:focuses_waittime].present?
      focus.lagtime_mask = params[:focuses_lagtime][checkbox_key] if params[:focuses_lagtime].present?
      focus.save

      #save any other focuses that have the same procedure and are in a specialization our clinic is in
      focus.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.map{ |ps2| Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(clinic.id, ps2.id) }.map{ |f| f.save }
    end
  end
end
