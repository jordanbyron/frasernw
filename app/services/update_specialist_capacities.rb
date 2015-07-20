module UpdateSpecialistCapacities
  def self.exec(specialist, params)
    return unless params[:capacities_mapped].present?

    specialist_specializations = specialist.specializations
    specialist.capacities.each do |original_capacity|
      if params[:capacities_mapped][original_capacity.procedure_specialization.id.to_s] == "0"
        original_capacity.destroy
      end
    end
    params[:capacities_mapped].each do |checkbox_key, value|
      if value == "1"
        capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(specialist.id, checkbox_key)
        capacity.investigation = params[:capacities_investigations][checkbox_key]
        capacity.waittime_mask = params[:capacities_waittime][checkbox_key] if params[:capacities_waittime].present?
        capacity.lagtime_mask = params[:capacities_lagtime][checkbox_key] if params[:capacities_lagtime].present?
        capacity.save

        #save any other capacities that have the same procedure and are in a specialization our specialist is in
        capacity.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.map{ |ps2| Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(specialist.id, ps2.id) }.map{ |c| c.save }
      end
    end
  end
end
