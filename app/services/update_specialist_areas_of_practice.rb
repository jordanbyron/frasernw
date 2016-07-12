class UpdateSpecialistAreasOfPractice
  attr_reader :specialist, :params

  # Note: 'specialist_areas_of_practice mapped' is an unfortunate name for the params coming in
  # They're actually procedure specialization ids

  def self.exec(specialist, params)
    new(specialist, params).exec
  end

  def initialize(specialist, params)
    @specialist = specialist
    @params = params
  end

  def exec
    return unless params[:specialist_areas_of_practice_mapped].present?

    specialist_specializations = specialist.specializations
    specialist.specialist_areas_of_practice.each do |specialist_area_of_practice|
      if params_indicate_destroy_specialist_area_of_practice?(specialist_area_of_practice)
        specialist_area_of_practice.destroy
      end
    end
    params[:specialist_areas_of_practice_mapped].each do |checkbox_key, value|
      if value == "1"
        specialist_area_of_practice = SpecialistAreaOfPractice.find_or_create_by(
          specialist_id: specialist.id,
          procedure_specialization_id: checkbox_key
        )
        specialist_area_of_practice.investigation = params[:specialist_areas_of_practice_investigations][checkbox_key]
        if params[:specialist_areas_of_practice_waittime].present?
          specialist_area_of_practice.waittime_mask = params[:specialist_areas_of_practice_waittime][checkbox_key]
        end
        if params[:specialist_areas_of_practice_lagtime].present?
          specialist_area_of_practice.lagtime_mask = params[:specialist_areas_of_practice_lagtime][checkbox_key]
        end
        specialist_area_of_practice.save

        # save any other specialist_areas_of_practice that have the same procedure and are in a
        # specialization our specialist is in
        specialist_area_of_practice.
          procedure_specialization.
          procedure.procedure_specializations.
          reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.
          map{ |ps2| SpecialistAreaOfPractice.find_or_create_by(
            specialist_id: specialist.id,
            procedure_specialization_id: ps2.id
          ) }.
          map{ |c| c.save }
      end
    end
  end

  # If this specialist has multiple specializations, they might have
  # a procedure which is attached to multiple specializations.
  # In this case, the form only serves procedure specialization checkboxes for
  # one of the specialization/procedure combinations, so we need to be sure to
  # check all procedure specialization ids for a given specialist_area_of_practice.
  def params_indicate_destroy_specialist_area_of_practice?(specialist_area_of_practice)
    specialist_area_of_practice.
      procedure.
      procedure_specializations.
      map(&:id).
      map(&:to_s).each do |id|
        if params[:specialist_areas_of_practice_mapped][id] == "0"
          return true
        end
      end

    false
  end
end
