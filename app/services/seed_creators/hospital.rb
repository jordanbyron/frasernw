module SeedCreators
  class Hospital < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      phone: Proc.new{ Faker::PhoneNumber.phone_number },
      fax: Proc.new{ |klass| Faker::PhoneNumber.phone_number },
      phone_extension: Proc.new{ |klass| Faker::PhoneNumber.extension },
      saved_token: Proc.new{ "demo_saved_token" },
    }
  end
end
