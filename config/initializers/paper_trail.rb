class Version < ActiveRecord::Base
  belongs_to :secret_token

  # nice past tense events for paper_trail
  def evented
    self.event.gsub('update','updated').gsub('destroy','destroyed').gsub('create','created')
  end

  def completely_masked?
    masked_changeset == {}
  end

  def masked_changeset
    changeset.reject do |key, value|
      item.paper_trail_ignored_attributes.include?(key.to_sym)
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
end
