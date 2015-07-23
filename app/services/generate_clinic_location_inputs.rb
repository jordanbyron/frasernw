# for specialists#edit
class GenerateClinicLocationInputs
  attr_reader :specializations

  def self.exec(specializations)
    new(specializations).exec
  end

  def initialize(specializations)
    @specializations = specializations
  end

  def exec
    specializations_locations = []
    specializations_clinic_locations = []

    specializations.each do |specialization|
      specialization.clinics.includes_location_data.each do |clinic|
        specializations_locations += formatted_locations(clinic)
        specializations_clinic_locations += formatted_clinic_locations(clinic)
      end
    end

    [
      specializations_locations.sort,
      specializations_clinic_locations.sort
    ]
  end

  def formatted_clinic_locations(clinic)
    clinic.clinic_locations.reject do |clinic_location|
      clinic_location.empty?
    end.map do |clinic_location|
      format_clinic_location(clinic_location, clinic)
    end
  end

  def format_clinic_location(clinic_location, clinic)
    [
      "#{clinic.name} - #{clinic_location.location.short_address}",
      clinic_location.id
    ]
  end

  def formatted_locations(clinic)
    clinic.locations.reject do |location|
      location.empty?
    end.map{ |location| format_location(location, clinic) }
  end

  def format_location(location, clinic)
    [
      "#{clinic.name} - #{location.short_address}",
      location.id
    ]
  end
end
