module UpdateSpecialistCapacities
  def self.exec(specialist, params)
    if params[:capacities_mapped].present?
      specialist_specializations = specialist.specializations
      specialist.capacities.each do |original_capacity|
        Capacity.destroy(original_capacity.id) if params[:capacities_mapped][original_capacity.procedure_specialization.id.to_s].blank?
      end
      params[:capacities_mapped].each do |updated_capacity, value|
        capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(specialist.id, updated_capacity)
        capacity.investigation = params[:capacities_investigations][updated_capacity]
        capacity.waittime_mask = params[:capacities_waittime][updated_capacity] if params[:capacities_waittime].present?
        capacity.lagtime_mask = params[:capacities_lagtime][updated_capacity] if params[:capacities_lagtime].present?
        capacity.save

        #save any other capacities that have the same procedure and are in a specialization our specialist is in
        capacity.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.map{ |ps2| Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(specialist.id, ps2.id) }.map{ |c| c.save }
      end
    end
  end
end
