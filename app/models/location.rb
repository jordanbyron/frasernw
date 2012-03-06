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
    if in_hospital?
      return hospital_in.address
    elsif in_clinic?
      return clinic_in.address
    else
      return address
    end
  end
  
  def city
    a = resolved_address
    return "" if a.blank?
    c = a.city
    c.present? ? c.name : ""
  end
  
  def short_address
    if in_clinic?
      if resolved_address.present?
        return "In #{clinic_in.name} - #{resolved_address.short_address}"
      else
        return "In #{clinic_in.name}, no address"
      end
    elsif in_hospital?
      if resolved_address.present?
        return "In #{hospital_in.name} - #{resolved_address.short_address}"
      else
        return "In #{hospital_in.name}, no address"
      end
    elsif resolved_address.present?
      return "#{resolved_address.short_address}"
    else
      return ""
    end
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
