# mixin for models so that we can call #history on them

module Historical
  def history
    GenerateHistory.call(target: self)
  end

  def notes_history
    GenerateHistory.call(
      target: self,
      event_types: [ GenerateHistory::Annotations ]
    )
  end
end
