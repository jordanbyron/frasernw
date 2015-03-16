class SubscriptionActivity < PublicActivity::Activity

  def self.created_at(date)
    where('created_at >= ?', date)
  end

  def self.by_update_classification(classification)
    where(update_classification_type: classification)
  end

  def self.by_divisions(divisions)
    where('owner_type = ?', "Division").where(owner_id: divisions)
  end

  def self.by_type_mask(type_mask_integer)
    where(type_mask: type_mask_integer)
  end

  def self.to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def self.collect_activities(date, classification, divisions, type_mask_integer)
    self.created_at(date)
    .by_update_classification(classification)
    .by_divisions(divisions)
    .by_type_mask(type_mask_integer)
    .reverse
  end
end