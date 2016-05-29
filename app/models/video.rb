class Video < ActiveRecord::Base

  def self.current
    ordered.first
  end

  def self.ordered
    order("created_at DESC")
  end

end
