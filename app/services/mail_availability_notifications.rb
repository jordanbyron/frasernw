class MailAvailabilityNotifications < ServiceObject
  def call
    Specialist.select do |specialist|
      (specialist.availability ==
        Specialist::AVAILABILITY_LABELS.key(:temporarily_unavailable)) &&
        (specialist.unavailable_to == Date.current + 1.weeks)
    end.each do |specialist|
      specialist.owners.each do |user|
        CourtesyMailer.availability_update(
          user.id,
          specialist.id
        ).deliver
      end
    end
  end
end
