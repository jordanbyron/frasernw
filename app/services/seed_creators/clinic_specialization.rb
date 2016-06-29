module SeedCreators
  class ClinicSpecialization < SeedCreator::HandledTable
    Handlers = {
      clinic_id: :pass_through,
      specialization_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
