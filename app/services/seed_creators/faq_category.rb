module SeedCreators
  class FaqCategory < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      description: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
