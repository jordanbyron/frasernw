module SeedCreators
  class SpecialistSpeak < SeedCreator::HandledTable
    Handlers = {
      specialist_id: :pass_through,
      language_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
