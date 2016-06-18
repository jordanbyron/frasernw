module SeedCreators
  class DemoableNewsItem < SeedCreator::HandledTable
    Handlers = {
      news_item_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through
    }
  end
end
