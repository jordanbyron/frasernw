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

  def specialist_specializations_listing(specialist)
    listing = ""

    if specialist.is_gp?
      listing += "GP "

      if specialist.specializations.many?
        listing += "with a focus in "
      end
    end

    specialist.specializations.not_family_practice.each do |specialization|
      listing += link_to(
        specialization.name,
        specialization_path(specialization)
      )
    end

    listing
  end
end
