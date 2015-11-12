class SecretToken < ActiveRecord::Base
  belongs_to :accessible, polymorphic: true
  belongs_to :creator, class_name: "User"

  include Rails.application.routes.url_helpers

  def creator_name
    if creator_id == 0
      "System"
    else
      creator.try(:name) || "Unknown User"
    end
  end

  def link
    send("#{accessible_type.downcase}_self_edit_path", accessible, token)
  end

  def as_hash
    {
      id: id,
      creator: creator_name,
      recipient: recipient,
      created_at: created_at.strftime("%Y-%m-%d"),
      link: link
    }
  end

end
