module UpdateClinicFocuses
  def self.exec(clinic, params)
    clinic_specializations = clinic.specializations
    if params[:focuses_mapped].present?
      clinic.focuses.each do |original_focus|
        Focus.destroy(original_focus.id) if params[:focuses_mapped][original_focus.procedure_specialization.id.to_s].blank?
      end
      params[:focuses_mapped].each do |updated_focus, value|
        focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(clinic.id, updated_focus)
        focus.investigation = params[:focuses_investigations][updated_focus]
        focus.waittime_mask = params[:focuses_waittime][updated_focus] if params[:focuses_waittime].present?
        focus.lagtime_mask = params[:focuses_lagtime][updated_focus] if params[:focuses_lagtime].present?
        focus.save

        #save any other focuses that have the same procedure and are in a specialization our clinic is in
        focus.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.map{ |ps2| Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(clinic.id, ps2.id) }.map{ |f| f.save }
      end
    end
  end
end
