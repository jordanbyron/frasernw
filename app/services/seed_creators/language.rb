module SeedCreators
  class Language < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      saved_token: Proc.new{ "demo_saved_token"},
    }
  end
end
