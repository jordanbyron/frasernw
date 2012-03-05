class SpecialistOffice < ActiveRecord::Base
  attr_accessible :phone, :fax, :office_id, :office_attributes
  
  belongs_to :specialist
  belongs_to :office
  accepts_nested_attributes_for :office
  
  has_paper_trail
  
  def phone_and_fax
    if phone.present? and fax.present?
      return "#{phone}, Fax: #{fax}"
    elsif phone.present?
      return "#{phone}"
    elsif fax.present?
      return "Fax: #{fax}"
    else
      return ""
    end
  end
  
  def empty?
    (phone.blank? and fax.blank? and office.blank?)
  end
end
