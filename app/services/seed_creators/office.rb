module SeedCreators
  class Office < SeedCreator::HandledTable
    Handlers = {
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
