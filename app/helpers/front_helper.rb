module FrontHelper
  def latest_events(max_automatic_events, divisions)
    LatestUpdates.call(
      max_automatic_events: max_automatic_events,
      division_ids: divisions.reject(&:hidden?)
    )
  end

  def favorite_featured_item(sc_item)
    id = sc_item.id
    title = escape_javascript(sc_item.title)

    "pathways.favoriteFeaturedItem(event, #{id}, '#{title}')"
  end

  def open_feedback_modal(sc_item)
    args = [
      "id: #{sc_item.id}",
      "itemType: 'ScItem'",
      "title: '#{sc_item.title}'",
      "modalState: 'PRE_SUBMIT'"
    ]

    "window.pathways.feedbackModal.setState({#{args.join(', ')}})"
  end
end
