module SeedCreators
  class NewsItem < SeedCreator::HandledTable
    Filter = Proc.new{ |news_item| news_item.demoable? }

    Handlers = {
      start_date: :pass_through,
      end_date: :pass_through,
      title: Proc.new{ "This is a title" },
      body: Proc.new{ "This is a news item." },
      created_at: :pass_through,
      updated_at: :pass_through,
      show_start_date: :pass_through,
      show_end_date: :pass_through,
      type_mask: :pass_through,
      owner_division_id: :pass_through,
      parent_id: :pass_through,
    }
  end
end
