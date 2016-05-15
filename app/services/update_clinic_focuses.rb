class UpdateClinicFocuses
  attr_reader :clinic, :params

  def self.exec(clinic, params)
    new(clinic, params).exec
  end

  def initialize(clinic, params)
    @clinic = clinic
    @params = params
  end

  def exec
    return unless params[:focuses_mapped].present?

    clinic.focuses.each do |focus|
      if params_indicate_destroy_focus?(focus)
        focus.destroy
      end
    end

    clinic_specializations = clinic.specializations
    params[:focuses_mapped].select do |checkbox_key, value|
      value == "1"
    end.each do |checkbox_key, value|
      focus = Focus.find_or_create_by(
        procedure_specialization_id: clinic.id,
        clinic_id: checkbox_key
      )
      focus.investigation = params[:focuses_investigations][checkbox_key]
      if params[:focuses_waittime].present?
        focus.waittime_mask = params[:focuses_waittime][checkbox_key]
      end
      if params[:focuses_lagtime].present?
        focus.lagtime_mask = params[:focuses_lagtime][checkbox_key]
      end
      focus.save

      # save any other focuses that have the same procedure and are in a
      # specialization our clinic is in
      focus.
        procedure_specialization.
        procedure.procedure_specializations.
        reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.
        map{ |ps2| Focus.find_or_create_by(
          clinic_id: clinic.id,
          procedure_specialization_id: ps2.id
        ) }.
        map{ |f| f.save }
    end
  end

  def params_indicate_destroy_focus?(focus)
    focus.
      procedure.
      procedure_specializations.
      map(&:id).
      map(&:to_s).each do |id|
        if params[:focuses_mapped][id] == "0"
          return true
        end
      end

    false
  end
end
