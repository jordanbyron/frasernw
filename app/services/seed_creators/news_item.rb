module SeedCreators
  class NewsItem < SeedCreator::HandledTable
    Filter = Proc.new{ |news_item| news_item.demoable? }

    Handlers = {
      start_date: Proc.new{ Date.yesterday },
      end_date: Proc.new{ 10.years.from_now },
      title: :pass_through,
      body: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      show_start_date: :pass_through,
      show_end_date: :pass_through,
      type_mask: :pass_through,
      owner_division_id: Proc.new{ 1 },
      parent_id: :pass_through,
    }
  end
end
