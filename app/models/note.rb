class Note < ActiveRecord::Base
  belongs_to :noteable, polymorphic: true
  belongs_to :user

  attr_accessible :content, :user, :user_id

  def self.find_by_noteable(id, type)
    where(noteable_id: id, noteable_type: type).first
  end

  def author_name
    user.name
  end
end
