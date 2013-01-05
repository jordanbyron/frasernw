module SpecializationsHelper
  def specialist_filtering_attributes(s, include_assumed)
    filtering_attributes = specialist_procedure_filtering_attributes(s)
    if include_assumed
      s.specializations.each do |specialization|
        specialization.procedure_specializations.assumed.each do |ps|
          filtering_attributes << "sp#{ps.procedure.id}_"
        end
      end
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
    filtering_attributes << "sshsat" if s.open_saturday?
    filtering_attributes << "sshsun" if s.open_sunday?
    filtering_attributes += specialist_association_filtering_attributes(s)
    filtering_attributes += specialist_language_filtering_attributes(s)
    return filtering_attributes
  end
  
  def specialist_procedure_filtering_attributes(s)
    filtering_attributes = []
    s.procedure_specializations.each do |ps|
      filtering_attributes << "sp#{ps.procedure.id}_"
      parent = ps.parent
      if parent.present?
        filtering_attributes << "sp#{parent.procedure.id}_" if !filtering_attributes.include?("sp#{parent.procedure.id}_")
        filtering_attributes << "sp#{parent.parent.procedure.id}_" if (parent.parent.present? && !filtering_attributes.include?("sp#{parent.parent.procedure.id}_"))
      end
    end
    filtering_attributes
  end
  
  def specialist_association_filtering_attributes(s)
    filtering_attributes = []
    s.clinics.each do |c|
      filtering_attributes << "sac#{c.id}_"
    end
    s.hospitals.each do |h|
      filtering_attributes << "sah#{h.id}_"
    end
    filtering_attributes
  end
  
  def specialist_language_filtering_attributes(s)
    filtering_attributes = []
    filtering_attributes << "si" if s.interpreter_available
    s.languages.each do |l|
      filtering_attributes << "sl#{l.id}_"
    end
    filtering_attributes
  end
  
  def office_filtering_attributes(s, include_assumed)
    filtering_attributes = []
    s.procedure_specializations.each do |ps|
      filtering_attributes << "op#{ps.procedure.id}_"
      parent = ps.parent
      if parent.present?
        filtering_attributes << "op#{parent.procedure.id}_" if !filtering_attributes.include?("op#{parent.procedure.id}_")
        filtering_attributes << "op#{parent.parent.procedure.id}_" if (parent.parent.present? && !filtering_attributes.include?("op#{parent.parent.procedure.id}_"))
      end
    end
    if include_assumed
      s.specializations.each do |specialization|
        specialization.procedure_specializations.assumed.each do |ps|
          filtering_attributes << "op#{ps.procedure.id}_"
        end
      end
    end
    if s.lagtime_mask.present?
      (s.lagtime_mask..Specialist::WAITTIME_HASH.length+1).each do |i|
        filtering_attributes << "oc#{i}_"
      end
    end
    filtering_attributes << "orph" if s.referral_phone
    filtering_attributes << "orpb" if s.patient_can_book?
    filtering_attributes << "osm" if s.male?
    filtering_attributes << "osf" if s.female?
    filtering_attributes << "oshsat" if s.open_saturday?
    filtering_attributes << "oshsun" if s.open_sunday?
    s.languages.each do |l|
      filtering_attributes << "ol#{l.id}_"
    end
    filtering_attributes << "oi" if s.interpreter_available
    s.clinics.each do |c|
      filtering_attributes << "oac#{c.id}_"
    end
    s.hospitals.each do |h|
      filtering_attributes << "oah#{h.id}_"
    end
    return filtering_attributes
  end
    
  def clinic_filtering_attributes(c)
    filtering_attributes = clinic_procedure_filtering_attributes(c)
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
    filtering_attributes += clinic_healthcare_provider_filtering_attributes(c)
    filtering_attributes += clinic_language_filtering_attributes(c)
    return filtering_attributes
  end
  
  def clinic_procedure_filtering_attributes(c)
    filtering_attributes = []
    c.procedure_specializations.each do |ps|
      filtering_attributes << "cp#{ps.procedure.id}_"
      parent = ps.parent
      if parent.present?
        filtering_attributes << "cp#{parent.procedure.id}_" if !filtering_attributes.include?("cp#{parent.procedure.id}_")
        filtering_attributes << "cp#{parent.parent.procedure.id}_" if (parent.parent.present? && !filtering_attributes.include?("cp#{parent.parent.procedure.id}_"))
      end
    end
    filtering_attributes
  end
  
  def clinic_language_filtering_attributes(c)
    filtering_attributes = []
    filtering_attributes << "ci" if c.interpreter_available
    c.languages.each do |l|
      filtering_attributes << "cl#{l.id}_"
    end
    filtering_attributes
  end
  
  def clinic_healthcare_provider_filtering_attributes(c)
    filtering_attributes = []
    c.healthcare_providers.each do |h|
      filtering_attributes << "ch#{h.id}_"
    end
    filtering_attributes
  end
  
  def other_specialists_in_cities(specialization, cities)
    other_specialists = []
    specialization.procedures.each do |p|
      next if p.specializations.length <= 1
      p.specializations.each do |s|
        next if s.id == specialization.id
        other_specialists << p.all_specialists_for_specialization_in_cities(s, cities)
      end
    end
    other_specialists = other_specialists.flatten.uniq
    #remove any specialists that are also in this specialization, sort
    return (other_specialists - specialization.specialists.in_cities(cities)).sort{ |a,b| "#{a.waittime_mask}" <=> "#{b.waittime_mask}" }
  end

  def sc_item_filtering_attributes(item)
    filtering_attributes = []
    filtering_attributes << "ic#{item.sc_category.id}_"
    item.specializations.each do |s|
      filtering_attributes << "is#{s.id}_"
    end
    item.procedure_specializations.each do |ps|
      filtering_attributes << "p#{ps.procedure.id}_"
    end
    return filtering_attributes
  end
end
