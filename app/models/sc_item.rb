class ScItem < ActiveRecord::Base
  attr_accessible :sc_category_id, :specialization_ids, :type_mask, :title, :url, :inline, :markdown_content
  
  belongs_to  :sc_category
  
  has_many    :sc_item_specializations, :dependent => :destroy
  has_many    :specializations, :through => :sc_item_specializations

  has_many    :sc_item_specialization_procedure_specializations, :through => :sc_item_specializations
  has_many    :procedure_specializations, :through => :sc_item_specialization_procedure_specializations
 
  validates_presence_of :title, :on => :create, :message => "can't be blank"
  
  def self.for_specialization(specialization)
    joins(:sc_item_specializations).where("sc_item_specializations.specialization_id == ?", specialization.id)
  end
  
  TYPE_HASH = {
    1 => "Link", 
    2 => "Markdown", 
  }
  
  def type
    SCItem::TYPE_HASH[type_mask]
  end

  def link?
    type_mask == 1
  end

  def markdown?
    type_mask == 2
  end

  def inline?
    inline
  end
end
