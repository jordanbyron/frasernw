module SeedCreators
  class Province < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      abbreviation: :pass_through,
      symbol: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
