module SeedCreators
  class Schedule < SeedCreator::HandledTable
    Handlers = {
      schedulable_type: :pass_through,
      schedulable_id: :pass_through,
      monday_id: :pass_through,
      tuesday_id: :pass_through,
      wednesday_id: :pass_through,
      thursday_id: :pass_through,
      friday_id: :pass_through,
      saturday_id: :pass_through,
      sunday_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
