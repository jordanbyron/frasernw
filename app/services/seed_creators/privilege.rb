module SeedCreators
  class Privilege < SeedCreator::HandledTable
    Handlers = {
      specialist_id: :pass_through,
      hospital_id: Proc.new{ model("Hospital").random_id },
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
