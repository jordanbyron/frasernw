class UpdateClinicAreasOfPractice
  attr_reader :clinic, :params

  def self.exec(clinic, params)
    new(clinic, params).exec
  end

  def initialize(clinic, params)
    @clinic = clinic
    @params = params
  end

  def exec
    return unless params[:clinic_areas_of_practice_mapped].present?

    clinic.clinic_areas_of_practice.each do |clinic_area_of_practice|
      if params_indicate_destroy_clinic_area_of_practice?(clinic_area_of_practice)
        clinic_area_of_practice.destroy
      end
    end

    clinic_specializations = clinic.specializations
    params[:clinic_areas_of_practice_mapped].select do |checkbox_key, value|
      value == "1"
    end.each do |checkbox_key, value|
      clinic_area_of_practice = clinic_area_of_practice.find_or_create_by(
        clinic_id: clinic.id,
        procedure_specialization_id: checkbox_key
      )
      clinic_area_of_practice.investigation = params[:clinic_areas_of_practice_investigations][checkbox_key]
      if params[:clinic_areas_of_practice_waittime].present?
        clinic_area_of_practice.waittime_mask = params[:clinic_areas_of_practice_waittime][checkbox_key]
      end
      if params[:clinic_areas_of_practice_lagtime].present?
        clinic_area_of_practice.lagtime_mask = params[:clinic_areas_of_practice_lagtime][checkbox_key]
      end
      clinic_area_of_practice.save

      # save any other clinic_areas_of_practice that have the same procedure and are in a
      # specialization our clinic is in
      clinic_area_of_practice.
        procedure_specialization.
        procedure.procedure_specializations.
        reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.
        map{ |ps2| clinic_area_of_practice.find_or_create_by(
          clinic_id: clinic.id,
          procedure_specialization_id: ps2.id
        ) }.
        map{ |f| f.save }
    end
  end

  def params_indicate_destroy_clinic_area_of_practice?(clinic_area_of_practice)
    clinic_area_of_practice.
      procedure.
      procedure_specializations.
      map(&:id).
      map(&:to_s).each do |id|
        if params[:clinic_areas_of_practice_mapped][id] == "0"
          return true
        end
      end

    false
  end
end
