module SeedCreators
  class DivisionCity < SeedCreator::HandledTable
    Handlers = {
      division_id: :pass_through,
      city_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
