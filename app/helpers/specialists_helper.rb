module SpecialistsHelper
  def clinic_associations(clinics)
    clinics.map do |clinic|
      if clinic.hidden?
        clinic.name
      else
        link_to(clinic.name, clinic_path(clinic))
      end
    end.to_sentence
  end
end
