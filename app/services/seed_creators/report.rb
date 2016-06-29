module SeedCreators
  class Report < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      type_mask: :pass_through,
      level_mask: :pass_through,
      division_id: :pass_through,
      city_id: :pass_through,
      user_type_mask: :pass_through,
      time_frame_mask: :pass_through,
      start_date: :pass_through,
      end_date: :pass_through,
      by_user: :pass_through,
      by_pageview: :pass_through,
      only_shared_care: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
