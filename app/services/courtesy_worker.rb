class CourtesyWorker
  def self.mail_availability_notifications
    Specialist.select do |specialist|
      (specialist.status_mask == 6) &&
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
