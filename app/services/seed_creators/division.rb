module SeedCreators
  class Division < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      primary_contact_id: :pass_through,
      use_customized_city_priorities: :pass_through,
    }
  end
end
