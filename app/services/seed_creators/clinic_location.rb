module SeedCreators
  class ClinicLocation < SeedCreator::HandledTable
    Handlers = {
      clinic_id: :pass_through,
      phone: Proc.new{ |klass| Faker::PhoneNumber.phone_number },
      fax: Proc.new{ |klass| Faker::PhoneNumber.phone_number },
      phone_extension: Proc.new{ |klass| Faker::PhoneNumber.extension },
      sector_mask: :pass_through,
      url: Proc.new{ |klass| "http://www.google.ca" },
      email: Proc.new{ Faker::Internet.email },
      contact_details: Proc.new{ |klass| "Some details." },
      wheelchair_accessible_mask: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      public_email: Proc.new{ Faker::Internet.email },
      location_opened: :pass_through,
      public: :pass_through,
      private: :pass_through,
      volunteer: :pass_through
    }
  end
end
