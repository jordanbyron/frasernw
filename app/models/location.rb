class Location < ActiveRecord::Base
  belongs_to :address
  accepts_nested_attributes_for :address
  
  belongs_to :locatable, :polymorphic => true
  
  belongs_to :hospital_in, :class_name => "Hospital"
  belongs_to :clinic_in, :class_name => "Clinic"
  
  has_paper_trail
  
  def empty?
    (not in_hospital?) && (not in_clinic?) && (address.blank? || address.empty?)
  end
  
  def in_hospital?
    hospital_in.present?
  end
  
  def in_clinic?
    clinic_in.present?
  end
  
  def resolved_address
    return hospital_in.resolved_address if in_hospital?
    return clinic_in.resolved_address if in_clinic?
    return address
  end
  
  def city
    a = resolved_address
    return "" if a.blank?
    c = a.city
    c.present? ? c.name : ""
  end
  
  def short_address
    output = ""
    output += "#{suite_in}, " if suite_in.present?
    output += "In #{hospital_in.name} " if in_hospital?
    output += "In #{clinic_in.name} " if in_clinic?
    output +=  " #{resolved_address.short_address}" if resolved_address.present?
    return output
  end
  
  def in_details
    if suite_in.present? and details_in.present?
      return "Suite #{suite_in}, #{details_in}"
    elsif suite_in.present?
      return "Suite #{suite_in}"
    elsif details_in.present?
      return "#{details_in}"
    else
      return ""
    end
  end
  
  def to_s
    return address.to_s
  end
end
