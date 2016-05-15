module SpecializationsHelper
  def specialist_filtering_attributes(s, include_assumed)
    filtering_attributes = specialist_procedure_filtering_attributes(s)
    filtering_attributes << "swt_#{s.waittime_mask.present? ? s.waittime_mask : 0}"
    s.procedure_specializations.specialist_wait_time.each do |ps|
      capacity =
        Capacity.find_by(specialist_id: s.id,procedure_specialization_id: ps.id)
      next if capacity.blank?
      if capacity.waittime_mask.present?
        filtering_attributes << "swt#{ps.procedure_id}_#{capacity.waittime_mask}"
      end
      if capacity.lagtime_mask.present?
        (capacity.lagtime_mask..Specialist::LAGTIME_LABELS.length+1).each do |i|
          filtering_attributes << "slt#{ps.procedure_id}_sc#{i}_"
        end
      end
    end
    if include_assumed
      s.specializations.each do |specialization|
        specialization.procedure_specializations.assumed_specialist.each do |ps|
          filtering_attributes << "sp#{ps.procedure_id}_"
        end
      end
    end
    if s.lagtime_mask.present?
      (s.lagtime_mask..Specialist::WAITTIME_LABELS.length+1).each do |i|
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
      filtering_attributes << "sp#{ps.procedure_id}_"
      parent = ps.parent
      if parent.present?
        if !filtering_attributes.include?("sp#{parent.procedure_id}_")
          filtering_attributes << "sp#{parent.procedure_id}_"
        end
        if (
          parent.parent.present? &&
          !filtering_attributes.include?("sp#{parent.parent.procedure_id}_")
        )
          filtering_attributes << "sp#{parent.parent.procedure_id}_"
        end
      end
    end
    filtering_attributes
  end

  def specialist_association_filtering_attributes(s)
    filtering_attributes = []
    s.clinics.each do |c|
      filtering_attributes << "sac#{c.id}_"
    end
    s.privileges.each do |p|
      filtering_attributes << "sah#{p.hospital_id}_"
    end
    filtering_attributes
  end

  def specialist_language_filtering_attributes(s)
    filtering_attributes = []
    filtering_attributes << "si" if s.interpreter_available
    s.specialist_speaks.each do |ss|
      filtering_attributes << "sl#{ss.language_id}_"
    end
    filtering_attributes
  end

  def office_filtering_attributes(s, include_assumed)
    filtering_attributes = []
    s.procedure_specializations.each do |ps|
      filtering_attributes << "op#{ps.procedure_id}_"
      parent = ps.parent
      if parent.present?
        if !filtering_attributes.include?("op#{parent.procedure_id}_")
          filtering_attributes << "op#{parent.procedure_id}_"
        end
        if (
          parent.parent.present? &&
          !filtering_attributes.include?("op#{parent.parent.procedure_id}_")
        )
          filtering_attributes << "op#{parent.parent.procedure_id}_"
        end
      end
    end
    filtering_attributes << "owt_#{s.waittime_mask.present? ? s.waittime_mask : 0}"
    s.procedure_specializations.specialist_wait_time.each do |ps|
      capacity =
        Capacity.find_by(specialist_id: s.id,procedure_specialization_id: ps.id)
      next if capacity.blank?
      if capacity.waittime_mask.present?
        filtering_attributes << "owt#{ps.procedure_id}_#{capacity.waittime_mask}"
      end
      if capacity.lagtime_mask.present?
        (capacity.lagtime_mask..Specialist::LAGTIME_LABELS.length+1).each do |i|
          filtering_attributes << "olt#{ps.procedure_id}_oc#{i}_"
        end
      end
    end
    if include_assumed
      s.specializations.each do |specialization|
        specialization.procedure_specializations.assumed_specialist.each do |ps|
          filtering_attributes << "op#{ps.procedure_id}_"
        end
      end
    end
    if s.lagtime_mask.present?
      (s.lagtime_mask..Specialist::WAITTIME_LABELS.length+1).each do |i|
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

  def clinic_filtering_attributes(c, include_assumed)
    filtering_attributes = clinic_procedure_filtering_attributes(c)
    filtering_attributes << "cwt_#{c.waittime_mask.present? ? c.waittime_mask : 0}"
    c.procedure_specializations.clinic_wait_time.each do |ps|
      focus = Focus.find_by(clinic_id: c.id, procedure_specialization_id: ps.id)
      next if focus.blank?
      if focus.waittime_mask.present?
        filtering_attributes << "cwt#{ps.procedure_id}_#{focus.waittime_mask}"
      end
      if focus.lagtime_mask.present?
        (focus.lagtime_mask..Clinic::LAGTIME_LABELS.length+1).each do |i|
          filtering_attributes << "clt#{ps.procedure_id}_cc#{i}_"
        end
      end
    end
    if include_assumed
      c.specializations.each do |specialization|
        specialization.procedure_specializations.assumed_clinic.each do |ps|
          filtering_attributes << "cp#{ps.procedure_id}_"
        end
      end
    end
    if c.lagtime_mask.present?
      (c.lagtime_mask..Specialist::WAITTIME_LABELS.length+1).each do |i|
        filtering_attributes << "cc#{i}_"
      end
    end
    filtering_attributes << "crph" if c.referral_phone
    filtering_attributes << "crpb" if c.patient_can_book?
    if c.private?
      filtering_attributes << "cdpv"
    else
      filtering_attributes << "cdpb"
    end
    filtering_attributes << "cdwa" if c.wheelchair_accessible?
    days = c.days
    filtering_attributes << "cshmon" if days.include? "Monday"
    filtering_attributes << "cshtues" if days.include? "Tuesday"
    filtering_attributes << "cshwed" if days.include? "Wednesday"
    filtering_attributes << "cshthurs" if days.include? "Thursday"
    filtering_attributes << "cshfri" if days.include? "Friday"
    filtering_attributes << "cshsat" if days.include? "Saturday"
    filtering_attributes << "cshsun" if days.include? "Sunday"
    filtering_attributes += clinic_healthcare_provider_filtering_attributes(c)
    filtering_attributes += clinic_language_filtering_attributes(c)
    return filtering_attributes
  end

  def clinic_procedure_filtering_attributes(c)
    filtering_attributes = []
    c.procedure_specializations.each do |ps|
      filtering_attributes << "cp#{ps.procedure_id}_"
      parent = ps.parent
      if parent.present?
        if !filtering_attributes.include?("cp#{parent.procedure_id}_")
          filtering_attributes << "cp#{parent.procedure_id}_"
        end
        if (
          parent.parent.present? &&
          !filtering_attributes.include?("cp#{parent.parent.procedure_id}_")
        )
          filtering_attributes << "cp#{parent.parent.procedure_id}_"
        end
      end
    end
    filtering_attributes
  end

  def clinic_language_filtering_attributes(c)
    filtering_attributes = []
    filtering_attributes << "ci" if c.interpreter_available
    c.clinic_speaks.each do |cs|
      filtering_attributes << "cl#{cs.language_id}_"
    end
    filtering_attributes
  end

  def clinic_healthcare_provider_filtering_attributes(c)
    filtering_attributes = []
    c.clinic_healthcare_providers.each do |chp|
      filtering_attributes << "ch#{chp.healthcare_provider_id}_"
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
    return (other_specialists - specialization.specialists.in_cities_cached(cities)).
      sort{ |a,b| "#{a.waittime_mask}" <=> "#{b.waittime_mask}" }
  end

  def other_clinics_in_cities(specialization, cities)
    other_clinics = []
    specialization.procedures.each do |p|
      next if p.specializations.length <= 1
      p.specializations.each do |s|
        next if s.id == specialization.id
        other_clinics << p.all_clinics_for_specialization_in_cities(s, cities)
      end
    end
    other_clinics = other_clinics.flatten.uniq
    #remove any specialists that are also in this specialization, sort
    return (other_clinics - specialization.clinics.in_cities(cities)).
      sort{ |a,b| "#{a.waittime_mask}" <=> "#{b.waittime_mask}" }
  end

  def sc_item_filtering_attributes(item)
    filtering_attributes = []
    filtering_attributes << "ic#{item.sc_category_id}_"
    item.specializations.each do |s|
      filtering_attributes << "is#{s.id}_"
    end
    item.procedure_specializations.each do |ps|
      filtering_attributes << "p#{ps.procedure_id}_"
    end
    return filtering_attributes
  end
end
