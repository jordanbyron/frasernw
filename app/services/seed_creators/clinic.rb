module SeedCreators
  class Clinic < SeedCreator::HandledTable
    Handlers = {
      name: Proc.new{ Faker::Company.name },
      interest: Proc.new{ "Post-surgical Counselling" },
      created_at: :pass_through,
      updated_at: :pass_through,
      referral_criteria: Proc.new{ "Laparascopic analysis" },
      referral_process: Proc.new{ "Email preferred." },
      contact_name: Proc.new{ "#{Faker::Name.first_name} #{Faker::Name.last_name}" },
      contact_phone: Proc.new{ Faker::PhoneNumber.phone_number },
      contact_email: Proc.new{ Faker::Internet.email },
      contact_notes: Proc.new do
        "We seek to provide the best possible medical care to our patients."
      end,
      status_mask: Proc.new{ (rand() < 0.9) ? 1 : (1..7).to_a.except(3).sample },
      limitations: Proc.new{ "Not wheelchair accessible" },
      location_opened_old: Proc.new{ "seeded_location_opened_old"},
      required_investigations: Proc.new{ "Complete medical history." },
      not_performed: Proc.new{ "Vaccinations" },
      referral_fax: Proc.new{ [true, false].sample },
      referral_phone: Proc.new{ [true, false].sample },
      referral_other_details: Proc.new{ "Some details." },
      referral_form_old: Proc.new{ true },
      respond_by_fax: Proc.new{ [true, false].sample },
      respond_by_phone: Proc.new{ [true, false].sample },
      respond_by_mail: Proc.new{ [true, false].sample },
      respond_to_patient: Proc.new{ [true, false].sample },
      patient_can_book_old: Proc.new{ [true, false].sample },
      red_flags: Proc.new{ "Oncology" },
      urgent_fax: Proc.new{ [true, false].sample },
      urgent_phone: Proc.new{ [true, false].sample },
      urgent_other_details: Proc.new{ "Some details." },
      waittime_mask: Proc.new{ model("Clinic")::WAITTIME_LABELS.keys.sample },
      lagtime_mask: Proc.new{ model("Clinic")::LAGTIME_LABELS.keys.sample },
      referral_form_mask: :pass_through,
      patient_can_book_mask: :pass_through,
      urgent_details: Proc.new{ "Some details." },
      deprecated_phone: Proc.new{ Faker::PhoneNumber.phone_number },
      deprecated_fax: Proc.new{ Faker::PhoneNumber.phone_number },
      deprecated_sector_mask: :pass_through,
      deprecated_wheelchair_accessible_mask: :pass_through,
      referral_details: Proc.new{ "Some details." },
      admin_notes: Proc.new do
        "We seek to provide the best possible medical care to our patients."
      end,
      deprecated_schedule_id: :pass_through,
      categorization_mask: Proc.new{ 1 },
      patient_instructions: Proc.new{ "Take no food 12 hours prior to appointment" },
      cancellation_policy: Proc.new{ "24 hour notice required." },
      deprecated_phone_extension: Proc.new{ Faker::PhoneNumber.extension },
      saved_token: Proc.new{ "seeded_saved_token"},
      interpreter_available: Proc.new { [true, false].sample },
      deprecated_contact_details: Proc.new{ "Some details." },
      status_details: Proc.new{ "Some details." },
      deprecated_url: Proc.new{ "http://www.google.ca" },
      deprecated_email: Proc.new{ Faker::Internet.email },
      unavailable_from: Proc.new{ rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) },
      hidden: :pass_through,
      completed_survey: Proc.new{ true },
      accepting_new_referrals: Proc.new{ rand() < 0.9 },
      referrals_limited: Proc.new{ rand() < 0.05 },
      is_open: Proc.new{ rand() < 0.95 }
    }
  end
end
