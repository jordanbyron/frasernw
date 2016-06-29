module SeedCreators
  class Version < SeedCreator::SkippedTable
    Model = PaperTrail::Version
  end
end
