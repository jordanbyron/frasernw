module FrontHelper
  def latest_events(max_automated_events, divisions)
    LatestUpdates.exec(
      max_automated_events: max_automated_events,
      divisions: divisions,
      force: false,
      force_automatic: false
    )
  end
end
