module SeedCreators
  class Specialist < SeedCreator::HandledTable
    Handlers = {
      firstname: Proc.new{ Faker::Name.first_name },
      lastname: Proc.new{ Faker::Name.last_name},
      practice_limitations: Proc.new{ "Not wheelchair accessible" },
      interest: Proc.new{ "Post-surgical Counselling" },
      created_at: :pass_through,
      updated_at: :pass_through,
      contact_name: Proc.new{ "#{Faker::Name.first_name} #{Faker::Name.last_name}" },
      contact_phone: Proc.new{ Faker::PhoneNumber.phone_number },
      contact_email: Proc.new{ Faker::Internet.email },
      red_flags: Proc.new{ "Oncology" },
      referral_criteria: Proc.new{ "Laparascopic analysis" },
      saved_token: Proc.new{ "seeded_saved_token"},
      contact_notes: Proc.new{ "This is how you should contact us" },
      not_interested: Proc.new{ "Post-surgical Counselling" },
      all_procedure_info: Proc.new do
        "Ensure records are provided at least 2 days prior to appiontment"
      end,
      referral_other_details: Proc.new{ "Some details." },
      urgent_other_details: Proc.new{ "Some details." },
      required_investigations: Proc.new{ "Complete medical history." },
      not_performed: Proc.new{ "Vaccinations" },
      status_details: Proc.new{ "Some details." },
      status_mask: Proc.new{ (rand() < 0.9) ? 1 : (1..7).to_a.except(3).sample },
      referral_fax: Proc.new{ [true, false].sample },
      referral_phone: Proc.new{ [true, false].sample },
      respond_by_fax: Proc.new{ [true, false].sample },
      respond_by_phone: Proc.new{ [true, false].sample },
      respond_by_mail: Proc.new{ [true, false].sample },
      respond_to_patient: Proc.new{ [ true, false].sample },
      urgent_fax: Proc.new{ [true, false].sample },
      urgent_phone: Proc.new{ [true, false].sample },
      waittime_mask: Proc.new{ model("Specialist")::WAITTIME_LABELS.keys.sample },
      lagtime_mask: Proc.new{ model("Specialist")::LAGTIME_LABELS.keys.sample },
      billing_number: Proc.new{ (5000..6000).to_a.sample },
      referral_form_mask: :pass_through,
      patient_can_book_mask: :pass_through,
      urgent_details: Proc.new{ "Some details." },
      goes_by_name: Proc.new{ "" },
      sex_mask: Proc.new{ [1, 2, 3].sample },
      referral_details: Proc.new{ "Some details." },
      admin_notes: Proc.new{ "Some notes" },
      categorization_mask: Proc.new{ rand() < 0.9 ? 1 : [3, 5].sample },
      patient_instructions: Proc.new{ "Take no food 12 hours prior to appiontment" },
      cancellation_policy: Proc.new{ "24 hour notice required." },
      referral_clinic_id: Proc.new{ model("Clinic").random_id },
      hospital_clinic_details: Proc.new{ "Some details." },
      interpreter_available: :pass_through,
      photo_file_name: Proc.new{ "demo_photo" },
      photo_content_type: Proc.new{ nil },
      photo_file_size: :pass_through,
      photo_updated_at: :pass_through,
      is_gp: :pass_through,
      is_internal_medicine: :pass_through,
      sees_only_children: :pass_through,
      hidden: :pass_through,
      completed_survey: Proc.new{ rand() < 0.95 },
      works_from_offices: Proc.new{ rand() < 0.8 },
      accepting_new_direct_referrals: Proc.new{ rand() < 0.75 },
      direct_referrals_limited: Proc.new{ rand() < 0.03 },
      practice_end_scheduled: Proc.new{ rand() < 0.05 },
      practice_end_reason_key: Proc.new{ Specialist::PRACTICE_END_REASONS.keys.sample },
      practice_end_date: Proc.new{ rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) },
      practice_restart_date: Proc.new{ rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) },
      practice_restart_scheduled: Proc.new{ false },
      practice_details: Proc.new{ "Some details" },
      accepting_new_indirect_referrals: Proc.new{ rand() < 0.05 },
      teleservices_require_review: Proc.new{ false },
      tagged_specialization_id: Proc.new{ nil }
    }
  end
end
