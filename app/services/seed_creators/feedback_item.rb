module SeedCreators
  class FeedbackItem < SeedCreator::HandledTable
    Handlers = {
      user_id: :pass_through,
      feedback: Proc.new{ "There is incorrect information on this page"},
      created_at: :pass_through,
      updated_at: :pass_through,
      archived: :pass_through,
      target_type: :pass_through,
      target_id: :pass_through,
      freeform_email: Proc.new{ "test@t.com" },
      freeform_name: Proc.new{ "John Smith" },
      archiving_division_ids: :pass_through
    }
  end
end
