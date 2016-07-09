module SeedCreators
  class ClinicAreaOfPractice < SeedCreator::HandledTable
    Handlers = {
      clinic_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      investigation: Proc.new{ "" },
      procedure_specialization_id: :pass_through,
      waittime_mask: Proc.new{ model("Clinic")::WAITTIME_LABELS.keys.sample },
      lagtime_mask: Proc.new{ model("Clinic")::LAGTIME_LABELS.keys.sample },
    }
  end
end
