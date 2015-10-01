class FeedbackItem < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable
  include Archivable

  belongs_to :item, :polymorphic => true

  belongs_to :user

  attr_accessible :feedback, :item_type, :item_id

  def in_divisions?(divisions)
    item.present? && (item.divisions & divisions).any?
  end

  def archived_by_divisions?(divisions)
    archived &&
      versions.last.present? &&
      versions.last.changeset.has_key?('archived') &&
      versions.last.changeset['archived'][1] &&
      (versions.last.safe_user.divisions & divisions).any?
  end

  def for_divisions?(divisions)
    in_divisions?(divisions) || archived_by_divisions?(divisions)
  end

  def label
    "#{item.name} (Feedback Item)"
  end

  def creator
    user
  end

  def active?
    !archived?
  end
end
