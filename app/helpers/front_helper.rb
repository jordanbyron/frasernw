module FrontHelper
  def scoped_news_item_archive_path(path, options = {})
    division_scope =
      if current_user.as_admin_or_super?
        { division_id: @as_division }
      else
        {}
      end

    send(path, options.merge(division_scope))
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

  def news_item_types_present
    [
      @news_items,
      @divisional_updates,
      @attachment_updates,
      @shared_care_updates
    ].
      reject(&:empty?).
      map do |news_items_type_batch|
        NewsItem::TYPE_HASH[news_items_type_batch.first.type_mask].pluralize
      end.to_sentence
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
