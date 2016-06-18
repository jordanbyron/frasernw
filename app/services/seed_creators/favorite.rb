module SeedCreators
  class Favorite < SeedCreator::HandledTable
    Handlers = {
      user_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      favoritable_id: :pass_through,
      favoritable_type: :pass_through,
    }
  end
end
