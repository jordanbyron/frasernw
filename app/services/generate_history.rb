class GenerateHistory
  # one subgenerator for each kind of lifecycle event
  # events should be mutually exclusive!
  # i.e. before I had 'archived' here, but that duplicates the 'update' events

  EVENT_TYPES = [
    Creation,
    LastUpdated,
    PriorUpdates,
    Annotations,
    ChildEvents
  ]

  attr_reader :target

  def initialize(target)
    @target = target
  end

  def exec
    return [] unless target.id.present?

    unsorted.sort_by {|node| node.datetime }
  end

  def unsorted
    EVENT_TYPES.inject([]) do |memo, event_type|
      memo + event_type.for(target)
    end
  end
end
