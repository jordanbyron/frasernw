class GenerateHistory
  # one subgenerator for each kind of lifecycle event
  # events should be mutually exclusive!
  # i.e. before I had 'archived' here, but that duplicates the 'update' events

  EVENT_TYPES = [
    :creation,
    :last_updated,
    :prior_updates,
    :annotations,
    :child_events
  ]

  attr_reader :target, :event_types

  def initialize(target, event_types = EVENT_TYPES)
    @target = target
    @event_types = event_types.map do |type_sym|
      "GenerateHistory::#{type_sym.to_s.camelize}".constantize
    end
  end

  def exec
    return [] unless target.id.present?

    unsorted.sort_by {|node| node.datetime }
  end

  def unsorted
    event_types.inject([]) do |memo, event_type|
      memo + event_type.for(target)
    end
  end
end
