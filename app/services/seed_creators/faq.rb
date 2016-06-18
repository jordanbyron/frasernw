module SeedCreators
  class Faq < SeedCreator::HandledTable
    Handlers = {
      question: :pass_through,
      answer_markdown: Proc.new{ "This is an answer to an FAQ question" },
      index: :pass_through,
      faq_category_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
