class SecretToken < ActiveRecord::Base
  belongs_to :accessible, polymorphic: true
  belongs_to :creator, class_name: "User"

  include Rails.application.routes.url_helpers

  def self.not_expired
    where(expired: false)
  end

  def creator_name
    if creator_id == 0
      "System"
    else
      creator.try(:name) || "Unknown User"
    end
  end

  def link(host)
    send("#{accessible_type.downcase}_self_edit_url", accessible, token, host: host)
  end

  def as_hash(host)
    {
      id: id,
      creator: creator_name,
      recipient: recipient,
      created_at: created_at.strftime("%Y-%m-%d"),
      link: link(host)
    }
  end

end
