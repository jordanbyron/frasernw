module SeedCreators
  class ContentItemSpecialtyAreaOfPracticeSpecialty < SeedCreator::HandledTable
    Handlers = {
      sc_item_specialization_id: :pass_through,
      procedure_specialization_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
