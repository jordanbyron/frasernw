# limit by max
# decorate with labels

class SpecialistLatestUpdates < ServiceObject

  def event_date(specialist, event_method)
    specialist.versions.order(:created_at).find_last do |version|
      !version.reify.present? || !version.reify.send(event_method)
    end.created_at
  end


  def call
    automated_events = []

    divisions = [ Division.find(1) ]

    Specialist.includes_specialization_page.includes(:versions).all.each do |specialist|
      specialist_cities = specialist.cities_for_front_page.flatten.uniq

      next if specialist.blank?

      next if !specialist.primary_specialization.present?
      next if !specialist.primary_specialization_complete_in?(divisions)
      #Below: Division's define what cities they refer to for specific specializations.  Do not show version if specialist specialization is not within local referral area of the division.
      next if (specialist_cities & divisions.map{|d| d.local_referral_cities(specialist.primary_specialization)}.flatten.uniq).blank?

      automated_events << {
        item: specialist,
        event: :moved_away,
        date: event_date(specialist, :moved_away?)
      } if specialist.moved_away?

      automated_events << {
        item: specialist,
        event: :retired,
        date: event_date(specialist, :retired?)
      } if specialist.retired?

      automated_events << {
        item: specialist,
        event: :retiring,
        date: event_date(specialist, :retiring?)
      } if specialist.retiring?
    end

    automated_events
  end
end
