module SeedCreators
  class ScCategory < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      show_on_front_page: :pass_through,
      sort_order: :pass_through,
      index_display_format: :pass_through,
      in_global_navigation: :pass_through,
      filterable: :pass_through,
      ancestry: :pass_through,
      searchable: :pass_through,
      evidential: :pass_through,
    }
  end
end
