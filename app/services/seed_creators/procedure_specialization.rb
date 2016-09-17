module SeedCreators
  class ProcedureSpecialization < SeedCreator::HandledTable
    Handlers = {
      procedure_id: :pass_through,
      specialization_id: :pass_through,
      ancestry: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      classification: :pass_through
    }
  end
end
