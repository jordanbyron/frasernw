module SeedCreators
  class ProcedureSpecialization < SeedCreator::HandledTable
    Handlers = {
      procedure_id: :pass_through,
      specialization_id: :pass_through,
      ancestry: :pass_through,
      mapped: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      classification: :pass_through,
      specialist_wait_time: :pass_through,
      clinic_wait_time: :pass_through,
    }
  end
end
