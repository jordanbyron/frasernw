module FrontHelper
  def latest_events(max_automated_events, divisions)
    LatestUpdates.call(
      max_automated_events: max_automated_events,
      division_ids: divisions.map(&:id),
      force: false,
      force_automatic: false
    )
  end
end
