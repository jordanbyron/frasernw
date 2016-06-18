module SeedCreators
  class Location < SeedCreator::HandledTable
    Handlers = {
      locatable_type: :pass_through,
      locatable_id: :pass_through,
      address_id: :pass_through,
      hospital_in_id: :pass_through,
      clinic_in_id: :pass_through,
      suite_in: Proc.new{ Faker::Address.secondary_address },
      details_in: Proc.new{ "Some details." },
      created_at: :pass_through,
      updated_at: :pass_through,
      location_in_id: :pass_through,
    }
  end
end
