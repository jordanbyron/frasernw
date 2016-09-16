class Version < PaperTrail::Version
  belongs_to :review_item

  attr_accessible :review_item_id

  BLACKLISTED = ['SecretToken']

  scope :no_blacklist, lambda { where("item_type != ?", BLACKLISTED) }

  # nice past tense events for paper_trail
  def evented
    self.
      event.
      gsub('update','updated').
      gsub('destroy','destroyed').
      gsub('create','created')
  end

  def completely_masked?
    masked_changeset == {}
  end

  def masked_changeset
    changeset.reject do |key, value|
      item.paper_trail_ignored_attributes.include?(key.to_sym)
    end
  end

  def secret_editor
    if review_item.present?
      review_item.editor
    else
      nil
    end
  end

  def archiving_item?
    changeset.has_key?('archived') && changeset['archived'][1] == true
  end

  def null_changeset?
    changeset == nil ||
      changeset == {} ||
      (changeset.keys.length == 1 && changeset.keys[0] == "review_object")
  end

  def safe_user
    User.safe_find(
      self.whodunnit,
      UnknownUser
    )
  end

  after_commit do
    PerformExtrajurisdictionalNotification.delay.call(version_id: self.id)
  end
end
