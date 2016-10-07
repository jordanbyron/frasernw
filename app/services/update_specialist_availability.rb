class UpdateSpecialistAvailability < ServiceObject
  def call
    Specialist.
      where(
        leave_scheduled: true,
        availability: Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      ).where(
        "unavailable_from >= (?) AND unavailable_to <= (?)",
        Date.current,
        Date.current
      ).update_all(
        availability: Specialist::AVAILABILITY_LABELS.key(:temporarily_unavailable)
      )

    Specialist.
      where(
        retirement_scheduled: true,
        availability: Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      ).where("retirement_date >= (?)", Date.current).
      update_all(
        availability: Specialist::AVAILABILITY_LABELS.key(:retired)
      )
  end
end
