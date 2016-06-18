module SeedCreators
  class ClinicHealthcareProvider < SeedCreator::HandledTable
    Handlers = {
      clinic_id: :pass_through,
      healthcare_provider_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
