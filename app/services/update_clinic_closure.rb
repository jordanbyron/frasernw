class UpdateClinicClosure < ServiceObject
  def call
    Clinic.
      where(
        closure_scheduled: true,
        is_open: true
      ).where("closure_date >= (?)", Date.current).
      update_all(
        is_open: false
      )
  end
end
