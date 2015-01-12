class SubscriptionActivity < PublicActivity::Activity

  def self.by_divisions(divisions)
    where('owner_type = ?', "Division").where(owner_id: divisions)
  end

  def self.created_at(date)
    where('created_at >= ?', date)
  end

  def self.by_update_classifications(classifications)
    where(update_classification_type: classifications)
  end

  def self.by_categorization(categorization)
    where(categorization: :categorization)
  end
end