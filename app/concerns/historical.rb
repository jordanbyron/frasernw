module Historical
  def history
    GenerateHistory.call(target: self)
  end

  def notes_history
    GenerateHistory.call(
      target: self,
      caller_event_types: [ GenerateHistory::Annotations ]
    )
  end
end
