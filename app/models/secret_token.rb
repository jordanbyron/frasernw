class SecretToken < ActiveRecord::Base
  attr_accessible :expired,
    :creator_id,
    :recipient,
    :accessible_id,
    :accessible_type,
    :token

  belongs_to :accessible, polymorphic: true

  include Rails.application.routes.url_helpers
  include Historical
  include PaperTrailable

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

  def link(host)
    "#{host}#{send("#{accessible_type.downcase}_self_edit_path", accessible, token)}"
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

  def as_hash(host, user)
    {
      id: id,
      creator: creator_name,
      recipient: recipient,
      created_at: created_at.strftime("%Y-%m-%d"),
      link: link(host),
      last_used: last_used,
      canExpire: expirable_by?(user)
    }
  end

  def expirable_by?(user)
    return true if user.super_admin?
    return true if user == creator
    return true if creator.is_a?(UnknownUser) && user.admin?
    return true if creator.is_a?(SystemUser) && user.admin?

    false
  end
end
