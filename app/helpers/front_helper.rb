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

  def self.news_item_class(news_item)
    news_item.date.present? ? "news_item_title" : "news_item_date"
  end

  def self.specialty_class(specialization, *divisions)
    if specialization.hidden_in?(*divisions)
      "hidden-from-users"
    else
      "hoverlabel"
    end
  end
end
