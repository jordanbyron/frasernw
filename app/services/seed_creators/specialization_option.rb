module SeedCreators
  class SpecializationOption < SeedCreator::HandledTable
    Handlers = {
      specialization_id: :pass_through,
      owner_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      division_id: :pass_through,
      hide_from_division_users: :pass_through,
      is_new: :pass_through,
      content_owner_id: :pass_through,
      open_to_type_key: :pass_through,
      open_to_sc_category_id: :pass_through,
      show_specialist_categorization_1: :pass_through,
      show_specialist_categorization_2: :pass_through,
      show_specialist_categorization_3: :pass_through,
      show_specialist_categorization_4: :pass_through,
      show_specialist_categorization_5: :pass_through,
    }
  end
end
