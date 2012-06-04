module SpecializationsHelper
  def specialist_filtering_attributes(s)
    filtering_attributes = []
    s.procedure_specializations.each do |ps|
      filtering_attributes << "sp#{ps.procedure.id}_"
      parent = ps.parent
      filtering_attributes << "sp#{parent.procedure.id}_" if (parent && !filtering_attributes.include?("sp#{parent.procedure.id}_"))
    end
    if s.lagtime_mask.present?
      (s.lagtime_mask..Specialist::WAITTIME_HASH.length+1).each do |i|
        filtering_attributes << "sc#{i}_"
      end
    end
    filtering_attributes << "srph" if s.referral_phone
    filtering_attributes << "srpb" if s.patient_can_book?
    filtering_attributes << "ssm" if s.male?
    filtering_attributes << "ssf" if s.female?
    s.languages.each do |l|
      filtering_attributes << "sl#{l.id}_"
    end
    s.clinics.each do |c|
      filtering_attributes << "sac#{c.id}_"
    end
    s.hospitals.each do |h|
      filtering_attributes << "sah#{h.id}_"
    end
    return filtering_attributes
  end
    
  def clinic_filtering_attributes(c)
    filtering_attributes = []
    c.procedure_specializations.each do |ps|
      filtering_attributes << "cp#{ps.procedure.id}_"
      parent = ps.parent
      filtering_attributes << "cp#{parent.procedure.id}_" if (parent && !filtering_attributes.include?("cp#{parent.procedure.id}_"))
    end
    if c.lagtime_mask.present?
      (c.lagtime_mask..Specialist::WAITTIME_HASH.length+1).each do |i|
        filtering_attributes << "cc#{i}_"
      end
    end
    filtering_attributes << "crph" if c.referral_phone
    filtering_attributes << "crpb" if c.patient_can_book?
    filtering_attributes << "cdpb" if c.sector_mask == 1 || c.sector_mask == 3
    filtering_attributes << "cdpv" if c.sector_mask == 2 || c.sector_mask == 3
    filtering_attributes << "cdwa" if c.wheelchair_accessible?
    if c.scheduled?
      schedule = c.schedule
      filtering_attributes << "cshmon" if schedule.monday.scheduled
      filtering_attributes << "cshtues" if schedule.tuesday.scheduled
      filtering_attributes << "cshwed" if schedule.wednesday.scheduled
      filtering_attributes << "cshthurs" if schedule.thursday.scheduled
      filtering_attributes << "cshfri" if schedule.friday.scheduled
      filtering_attributes << "cshsat" if schedule.saturday.scheduled
      filtering_attributes << "cshsun" if schedule.sunday.scheduled
    end
    c.healthcare_providers.each do |h|
      filtering_attributes << "ch#{h.id}_"
    end
    c.languages.each do |l|
      filtering_attributes << "cl#{l.id}_"
    end
  end
  
  def other_specialists(specialization)
    other_specialists = []
    specialization.procedures.each do |p|
      next if p.specializations.length <= 1
      p.specializations.each do |s|
        next if s.id == specialization.id
        other_specialists << p.all_specialists_for_specialization(s)
      end
    end
    return other_specialists.flatten.uniq
  end
end
