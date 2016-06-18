module SeedCreators
  class NewsletterDescriptionItem < SeedCreator::HandledTable
    Handlers = {
      description_item: :pass_through,
      newsletter_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
