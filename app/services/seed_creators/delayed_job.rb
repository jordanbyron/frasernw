module SeedCreators
  class DelayedJob < SeedCreator::SkippedTable
    Model = Delayed::Job
  end
end
