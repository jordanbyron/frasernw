module SeedCreators
  class Teleservice < SeedCreator::HandledTable
    Handlers = {
      teleservice_provider_id: :pass_through,
      teleservice_provider_type: :pass_through,
      service_type_key: :pass_through,
      telephone: Proc.new{ rand() < 0.03 },
      video: Proc.new{ rand() < 0.03 },
      email: Proc.new{ rand() < 0.03 },
      store: Proc.new{ rand() < 0.03 },
      contact_note: Proc.new{ (rand() < 0.03) ? "Teleservice details" : "" },
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
