module SeedCreators
  class ClinicSpeak < SeedCreator::HandledTable
    Handlers = {
      clinic_id: :pass_through,
      language_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
