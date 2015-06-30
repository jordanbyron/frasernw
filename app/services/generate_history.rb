class GenerateHistory
  attr_reader :target

  def self.can_get?(event_type, options)
    event_type.generator_for? options[:for]
  end

  def initialize(target)
    @target = target
  end

  # one subgenerator for each kind of lifecycle event
  def event_types
    [
      Creation,
      LastUpdated,
      PriorUpdates,
      Annotations,
      Children
    ]
  end

  def exec
    event_types.inject([]) do |memo, event_type|
      if target.tracks?(event_type)
        memo + event_type.for(target)
      else
        memo
      end
    end
  end
end
