module SeedCreators
  class Address < SeedCreator::HandledTable
    Handlers = {
      address1: Proc.new{ Faker::Address.street_address },
      suite: Proc.new{ Faker::Address.secondary_address },
      postalcode: Proc.new{ Faker::Address.postcode },
      phone1: Proc.new{ Faker::PhoneNumber.phone_number },
      fax: Proc.new{ Faker::PhoneNumber.phone_number },
      created_at: :pass_through,
      updated_at: :pass_through,
      hospital_id: :pass_through,
      city_id: Proc.new{ |current| current.nil? ? nil : model("City").random_id },
      address2: Proc.new{ Faker::Address.street_address },
      clinic_id: :pass_through
    }
  end
end
