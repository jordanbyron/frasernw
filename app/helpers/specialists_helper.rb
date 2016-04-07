module SpecialistsHelper
  def specialist_works_out_of(specialist)
    if specialist.hospitals.any? && specialist.open_clinics.any?
      ("Only works out of " +
        (specialist.open_clinics.many? ? "clinics" : "a clinic") +
        " and " +
        (specialist.hospitals.many? ? "hospitals" : "a hospital") +
        ", and in general all referrals should be made through these locations.")
    elsif specialist.open_clinics.any?
      ("Only works out of " +
        (specialist.open_clinics.many? ? "clinics" : "a clinic") +
        ", and in general all referrals should be made through " +
        (specialist.open_clinics.many? ? "these clinics." : "this clinic."))
    elsif hospital_count > 0
      ("Only works out of " +
        (specialist.hospitals.many? ? "hospitals" : "a hospital") +
        ".")
    else
      "Only works out of hospitals and / or clinics, but we do not yet have data on which ones."
    end
  end
end
