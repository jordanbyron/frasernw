module FrontHelper
  def latest_events(max_automatic_events, divisions)
    LatestUpdates.call(
      max_automatic_events: max_automatic_events,
      division_ids: divisions.reject(&:hidden?)
    )
  end
end
