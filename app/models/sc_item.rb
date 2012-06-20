class ScItem < ActiveRecord::Base
  attr_accessible :name, :sc_category_id, :specialization_ids
  
  belongs_to  :sc_category
  
  has_many    :sc_item_specializations, :dependent => :destroy
  has_many    :specializations, :through => :sc_item_specializations
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  #validates_presence_of :sc_category, :on => :create, :message => "can't be blank"
  
  def self.for_specialization(specialization)
    joins(:sc_item_specializations).where("sc_item_specializations.specialization_id == ?", specialization.id)
  end
end
