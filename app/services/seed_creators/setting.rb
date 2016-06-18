module SeedCreators
  class Setting < SeedCreator::HandledTable
    Handlers = {
      value: :pass_through,
      identifier: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
