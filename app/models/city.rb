class City < ActiveRecord::Base
  attr_accessible :name, :province_id
  has_paper_trail meta: { to_review: false }
  
  belongs_to :province
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def to_s
    self.name
  end
end
