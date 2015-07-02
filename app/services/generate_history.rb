class GenerateHistory
  # one subgenerator for each kind of lifecycle event
  EVENT_TYPES = [
    Creation,
    LastUpdated,
    PriorUpdates,
    Annotations,
    ChildEvents
  ]

  def self.can_get?(event_type, options)
    event_type.generator_for? options[:for]
  end

  attr_reader :target

  def initialize(target)
    @target = target
  end

  def exec
    unsorted.sort_by {|node| node.datetime }
  end

  def unsorted
    EVENT_TYPES.inject([]) do |memo, event_type|
      memo + event_type.for(target)
    end
  end
end
