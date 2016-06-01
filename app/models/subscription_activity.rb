class SubscriptionActivity < PublicActivity::Activity
  def self.by_target_type(type)
    where(update_classification_type: type)
  end

  def self.by_divisions(divisions)
    where('owner_type = ?', "Division").where(owner_id: divisions)
  end

  def self.by_news_item_type(news_type)
    where(type_mask: news_type)
  end

  def self.by_sc_item_format_type(sc_item_format_type)
    where(format_type: sc_item_format_type)
  end

  def self.by_specializations(specializations)

    if specializations.present?
      where(trackable_type: "ScItem" || "ScCategory")
    else
      scoped
    end
  end

  def self.to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def self.all_resource_activities
    by_target_type(Subscription.resource_update)
  end

  def type_mask_description_formatted
    case type_mask_description
    when "Markdown"
      "Markdown content"
    when "Breaking News"
      "Breaking News"
    else
      type_mask_description.indefinitize
    end
  end
end
