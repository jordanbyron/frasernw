module SeedCreators
  class Evidence < SeedCreator::HandledTable
    Handlers = {
      level: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      quality_of_evidence: :pass_through,
      definition: :pass_through,
    }
  end
end
