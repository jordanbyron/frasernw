# mixin for models so that we can call #history on them

module Historical
  def history
    GenerateHistory.new(self).exec
  end

  def tracks?(event_type)
    GenerateHistory.can_get?(event_type, for: self)
  end
end
