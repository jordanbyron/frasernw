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

  def newsletter_section_heading(current_newsletter)
    if current_newsletter.new?
      "New Pathways Newsletter"
    else
      "Pathways Newsletter"
    end
  end
end
