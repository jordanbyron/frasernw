module SeedCreators
  class FeedbackItem < SeedCreator::HandledTable
    Handlers = {
      item_type: :pass_through,
      item_id: :pass_through,
      user_id: :pass_through,
      feedback: Proc.new{ "There is incorrect information on this page"},
      created_at: :pass_through,
      updated_at: :pass_through,
      archived: :pass_through,
    }
  end
end
