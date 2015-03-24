class SubscriptionActivity < PublicActivity::Activity

  def self.created_at(date)
    where('created_at >= ?', date) if date.present?
  end

  def self.by_update_classification(classification)
    if classification.present?
      where(update_classification_type: classification)
    else
      all
    end
  end

  def self.by_divisions(divisions)
    if divisions.present?
      where('owner_type = ?', "Division").where(owner_id: divisions)
    else
      where('owner_type = ?', "Division").where(owner_id: "") # defaults to ALL divisions to stop break in method chaining (e.g.: .all.all)
    end
  end

  def self.by_type_mask(type_mask_integer)
    if type_mask_integer.present?
      where(type_mask: type_mask_integer)
    else
      all
    end
  end

  def self.to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def self.collect_activities(date, classification, divisions, type_mask_integer)
    self.includes(:trackable).created_at(date).by_update_classification(classification).by_divisions(divisions).by_type_mask(type_mask_integer).reverse
  end
end