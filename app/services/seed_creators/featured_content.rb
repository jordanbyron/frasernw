module SeedCreators
  class FeaturedContent < SeedCreator::HandledTable
    Handlers = {
      sc_category_id: :pass_through,
      sc_item_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      division_id: :pass_through,
    }
  end
end
