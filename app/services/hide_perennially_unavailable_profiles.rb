class HidePerenniallyUnavailableProfiles < ServiceObject
  def call
    Specialist.all.select do |specialist|
      !specialist.practicing? &&
        specialist.practice_end_date < 2.years.ago
    end.map{|specialist| specialist.update_attributes(hidden: true) }

    Clinic.all.select do |clinic|
      clinic.closed? && clinic.closure_date < 2.years.ago
    end.map{|clinic| clinic.update_attributes(hidden: true) }
  end
end
