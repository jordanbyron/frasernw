module SeedCreators
  class Note < SeedCreator::HandledTable
    Handlers = {
      content: Proc.new{ "Some administrator note." },
      user_id: :pass_through,
      noteable_id: :pass_through,
      noteable_type: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
