module SeedCreators
  class DivisionPrimaryContact < SeedCreator::HandledTable
    Handlers = {
      division_id: :pass_through,
      primary_contact_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
