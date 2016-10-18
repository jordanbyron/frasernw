class MailLeaveEndingNotifications < ServiceObject
  def call
    Specialist.select do |specialist|
      specialist.went_on_leave? &&
        specialist.practice_restart_scheduled? &&
        specialist.practice_restart_date == (Date.current + 1.weeks)
    end.each do |specialist|
      specialist.owners.each do |user|
        CourtesyMailer.leave_ending(
          user.id,
          specialist.id
        ).deliver
      end
    end
  end
end
