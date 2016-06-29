module SeedCreators
  class DivisionDisplayScItem < SeedCreator::HandledTable
    Handlers = {
      division_id: :pass_through,
      sc_item_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
