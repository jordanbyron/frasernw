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

  def creator
    User.where(id: creator_id).first || OpenStruct.new(name: "System")
  end

  def creator_name
    creator.name
  end

  def link(host)
    "#{host}#{send("#{accessible_type.downcase}_self_edit_path", accessible, token)}"
  end

  def numbered_label
    "Secret Edit Link ##{id} for #{recipient}"
  end

  def as_hash(host, user)
    {
      id: id,
      creator: creator_name,
      recipient: recipient,
      created_at: created_at.strftime("%Y-%m-%d"),
      link: link(host),
      canExpire: expirable_by?(user)
    }
  end

  def expirable_by?(user)
    return true if user.super_admin?
    return true if user == creator
    return true if creator.nil? && user.admin?

    false
  end
end
