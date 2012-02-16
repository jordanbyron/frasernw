class User < ActiveRecord::Base
  acts_as_authentic
  has_many :favorites
  has_many :specialists, :through => :favorites
  
  has_many :user_controls_specialists
  has_many :controlled_specialists, :through => :user_controls_specialists, :source => :specialist, :class_name => "Specialist"
  accepts_nested_attributes_for :user_controls_specialists, :reject_if => lambda { |ucs| ucs[:specialist_id].blank? }, :allow_destroy => true

  # times that the user (as admin) has contacted specialistscreate 
  has_many :contacts

  # has_many :clinics,     :through => :favorites
  validates_presence_of :name
  validates_presence_of :username
  validates_presence_of :email
  
  default_scope order('name')
  
  def admin?
    self.role == 'admin'
  end
end
