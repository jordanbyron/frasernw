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
        capacity = Capacity.find_or_create_by(
          specialist_id: specialist.id,
          procedure_id: ProcedureSpecialization.find(checkbox_key).procedure_id
        )
        capacity.investigation = params[:capacities_investigations][checkbox_key]
        if params[:capacities_waittime].present?
          capacity.waittime_mask = params[:capacities_waittime][checkbox_key]
        end
        if params[:capacities_lagtime].present?
          capacity.lagtime_mask = params[:capacities_lagtime][checkbox_key]
        end
        capacity.save

        # save any other capacities that have the same procedure and are in a
        # specialization our specialist is in
        capacity.
          procedure.
          procedure_specializations.
          select do |procedure_specialization|
            specialist_specializations.
              include?(procedure_specialization.specialization)
          end.map do |procedure_specialization|
            Capacity.find_or_create_by(
              specialist_id: specialist.id,
              procedure_id: procedure_specialization.procedure_id
            )
          end.map{ |capacity| capacity.save }
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
