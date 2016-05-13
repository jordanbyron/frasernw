class Video < ActiveRecord::Base
  attr_accessible :title, :link

  def self.current
    ordered.first
  end

  def self.ordered
    order("created_at DESC")
  end

end
