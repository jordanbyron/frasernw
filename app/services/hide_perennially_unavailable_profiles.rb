class HidePerenniallyUnavailableProfiles < ServiceObject
  def call
    Specialist.all.select do |specialist|
      (specialist.retired? &&
        ((specialist.retirement_date || specialist.event_date(:retired?)) <
          date_cutoff)) ||
        (specialist.moved_away? && specialist.event_date(:moved_away?) <
          date_cutoff) ||
        (specialist.deceased? && specialist.event_date(:deceased?) <
          date_cutoff) ||
        (specialist.indefinitely_unavailable? &&
          specialist.event_date(:indefinitely_unavailable?) < date_cutoff)
    end.map{|specialist| specialist.update_attributes(hidden: true) }

    Clinic.all.select do |clinic|
      clinic.closed? && clinic.event_date(:closed?) < date_cutoff
    end.map{|clinic| clinic.update_attributes(hidden: true) }
  end

  def date_cutoff
    @date_cutoff ||= Date.current - 2.years
  end
end
