class Video < ActiveRecord::Base
  validates_presence_of [:title, :video_url],
    on: :create,
    message: "can't be blank"

  def self.current
    ordered.first
  end

  def self.ordered
    order("created_at ASC")
  end

end
