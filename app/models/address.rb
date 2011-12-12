class Address < ActiveRecord::Base
  has_paper_trail
  belongs_to :hospital
  
  def empty?
    address1.blank? and address2.blank? and city.blank? and province.blank? and postalcode.blank? and phone1.blank? and fax.blank? and hospital_id.blank?
  end
end
