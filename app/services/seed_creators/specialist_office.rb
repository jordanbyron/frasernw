module SeedCreators
  class SpecialistOffice < SeedCreator::HandledTable
    Filter = Proc.new{ |specialist_office| !specialist_office.office_id.nil? }

    Handlers = {
      specialist_id: :pass_through,
      office_id: :pass_through,
      phone: Proc.new{ Faker::PhoneNumber.phone_number },
      fax: Proc.new{ Faker::PhoneNumber.phone_number },
      created_at: :pass_through,
      updated_at: :pass_through,
      phone_extension: Proc.new{ Faker::PhoneNumber.extension },
      sector_mask: :pass_through,
      direct_phone: Proc.new{ Faker::PhoneNumber.phone_number },
      direct_phone_extension: Proc.new{ Faker::PhoneNumber.extension },
      url: Proc.new{ "http://www.google.ca" },
      email: Proc.new{ Faker::Internet.email },
      contact_details: Proc.new{ |klass| "Some details." },
      open_saturday: :pass_through,
      open_sunday: :pass_through,
      schedule_id: :pass_through,
      public_email: Proc.new{ Faker::Internet.email },
      location_opened: :pass_through,
      public: :pass_through,
      private: :pass_through,
      volunteer: :pass_through,
    }
  end
end
