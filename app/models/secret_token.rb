class SecretToken < ActiveRecord::Base
  attr_accessible :expired,
    :creator_id,
    :recipient,
    :accessible_id,
    :accessible_type,
    :token

  belongs_to :accessible, polymorphic: true


  include Historical
  include PaperTrailable

  ROUTES = Rails.application.routes.url_helpers

  def self.not_expired
    where(expired: false)
  end

  def review_items
    ReviewItem.where(edit_source_type: "SecretToken", edit_source_id: id.to_s)
  end

  def creator
    if creator_id == 0
      # migrated from previous system

      SystemUser.new
    else
      User.where(id: creator_id).first || UnknownUser.new
    end
  end

  def creator_name
    creator.name
  end

  def link
    ROUTES.send(
      "#{accessible_type.downcase}_self_edit_url",
      accessible,
      token
    )
  end

  def numbered_label
    if creator.is_a?(SystemUser)
      "Secret Edit Link ##{id} (migrated from previous system)"
    else
      "Secret Edit Link ##{id} (recipient: #{recipient})"
    end
  end

  def last_used
    if creator.is_a?(SystemUser)
      "Unknown"
    else
      review_items.last.try(:created_at).try(:to_date).try(:to_s, :ordinal) || ""
    end
  end

  def as_hash(user)
    {
      id: id,
      creator: creator_name,
      recipient: recipient,
      created_at: created_at.strftime("%Y-%m-%d"),
      link: link,
      last_used: last_used,
      canExpire: expirable_by?(user)
    }
  end

  def expirable_by?(user)
    return true if user.as_super_admin?
    return true if user == creator
    return true if creator.is_a?(UnknownUser) && user.admin_or_super?
    return true if creator.is_a?(SystemUser) && user.admin_or_super?

    false
  end

  def recipient_user
    SecretEditor.new(recipient)
  end
end
