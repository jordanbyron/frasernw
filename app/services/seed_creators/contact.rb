module SeedCreators
  class Contact < SeedCreator::HandledTable
    Handlers = {
      specialist_id: :pass_through,
      user_id: :pass_through,
      notes: Proc.new do
        "We seek to provide the best possible medical care to our patients."
      end,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
