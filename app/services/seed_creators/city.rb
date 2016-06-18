module SeedCreators
  class City < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      province_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      hidden: :pass_through,
    }
  end
end
