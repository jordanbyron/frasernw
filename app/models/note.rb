class Note < ActiveRecord::Base
  # review item
  # feedback item
  # sc item
  # referral form
  belongs_to :noteable, polymorphic: true
  belongs_to :user

  attr_accessible :content

  def self.find_by_noteable(id, type)
    where(noteable_id: id, noteable_type: type).first
  end

  def author_name
    user.name
  end
end
