class UpdateSpecialistCapacities
  attr_reader :specialist, :params

  # Note: 'capacities mapped' is an unfortunate name for the params coming in
  # They're actually procedure specialization ids

  def self.exec(specialist, params)
    new(specialist, params).exec
  end

  def initialize(specialist, params)
    @specialist = specialist
    @params = params
  end

  def exec
    return unless params[:capacities_mapped].present?

    specialist_specializations = specialist.specializations
    specialist.capacities.each do |capacity|
      if params_indicate_destroy_capacity?(capacity)
        capacity.destroy
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

  # If this specialist has multiple specializations, they might have
  # a procedure which is attached to multiple specializations.
  # In this case, the form only serves procedure specialization checkboxes for
  # one of the specialization/procedure combinations, so we need to be sure to
  # check all procedure specialization ids for a given capacity.
  def params_indicate_destroy_capacity?(capacity)
    capacity.
      procedure.
      procedure_specializations.
      map(&:id).
      map(&:to_s).each do |id|
        if params[:capacities_mapped][id] == "0"
          return true
        end
      end

    false
  end
end
