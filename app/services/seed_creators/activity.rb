module SeedCreators
  class Activity < SeedCreator::SkippedTable
    Model = PublicActivity::Activity
  end
end
