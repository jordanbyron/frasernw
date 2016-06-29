module SeedCreators
  class ScheduleDay < SeedCreator::HandledTable
    Handlers = {
      scheduled: :pass_through,
      from: :pass_through,
      to: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      break_from: :pass_through,
      break_to: :pass_through,
    }
  end
end
