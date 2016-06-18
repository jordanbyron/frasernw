module SeedCreators
  class LatestUpdatesMask < SeedCreator::HandledTable
    Handlers = {
      event_code: :pass_through,
      division_id: :pass_through,
      date: :pass_through,
      item_type: :pass_through,
      item_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
