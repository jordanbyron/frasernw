module SeedCreators
  class ClinicSpecialist < SeedCreator::HandledTable
    Handlers = {
      specialist_id: :pass_through,
      clinic_location_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      is_specialist: :pass_through,
      freeform_firstname: Proc.new{ Faker::Name.first_name },
      freeform_lastname: Proc.new{ Faker::Name.last_name},
      area_of_focus: Proc.new{ "Post-surgical recuperation" }
    }
  end
end
