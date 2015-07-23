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

    specializations.each do |s|
      specializations_locations += s.clinics.map do |clinic|
        formatted_locations(clinic)
      end.flatten(1)

      specializations_clinic_locations += s.clinics.map do |clinic|
        formatted_clinic_locations(clinic)
      end.flatten(1)
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
      format_clinic_location(clinic_location)
    end
  end

  def format_clinic_location(clinic_location)
    [
      "#{clinic_location.clinic.name} - #{clinic_location.location.short_address}",
      clinic_location.id
    ]
  end

  def formatted_locations(clinic)
    clinic.locations.map{ |location| format_location(location) }
  end

  def format_location(location)
    [
      "#{location.locatable.clinic.name} - #{location.short_address}",
      location.id
    ]
  end
end
