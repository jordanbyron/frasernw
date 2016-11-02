class UpdateReturnedSpecialists < ServiceObject
  def call
    Specialist.
      where(practice_end_scheduled: true, practice_restart_scheduled: true).
      where("practice_restart_date <= (?)", Date.current).
      update_all(practice_end_scheduled: false, practice_restart_scheduled: false)
  end
end
