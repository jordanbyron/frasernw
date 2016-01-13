module FrontHelper
  def latest_events(max_automated_events, divisions)
    LatestUpdates.call(
      max_automated_events: max_automated_events,
      division_ids: divisions.map(&:id)
    )
  end
end
