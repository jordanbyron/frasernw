class FeedbackItem < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable
  include Archivable

  belongs_to :target, polymorphic: true

  belongs_to :user

  attr_accessible :feedback,
    :target_type,
    :target_id,
    :freeform_name,
    :freeform_email,
    :user_id,
    :user,
    :archiving_division_ids,
    :archived

  def self.specialist
    where(target_type: "Specialist")
  end

  def self.clinic
    where(target_type: "Clinic")
  end

  def self.content
    where(target_type: "ScItem")
  end

  def self.general
    where("target_type = '' OR target_type IS NULL")
  end

  def in_divisions?(divisions)
    item.present? && (item.divisions & divisions).any?
  end

  def target_label
    if target
      target.label
    else
      "Deleted Item"
    end
  end

  def submitter_name
    if user.nil?
      freeform_name
    else
      user.name
    end
  end

  def submitter_email
    if user.nil?
      freeform_email
    else
      user.email
    end
  end

  def owners
    if general? && user.nil?
      Division.provincial.general_feedback_owner
    elsif general?
      user.divisions.map(&:general_feedback_owner)
    else
      target.owners
    end
  end

  def general?
    target_type.nil?
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
