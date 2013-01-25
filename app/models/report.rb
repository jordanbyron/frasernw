class Report < ActiveRecord::Base
  
  attr_accessible :name, :type_mask, :level_mask, :division_id, :city_id, :user_type_mask, :time_frame_mask, :start_date, :end_date
  
  belongs_to :division
  belongs_to :city
  
  TYPE_HASH = {
    1 => "General page piews",
    2 => "Users",
    3 => "Specialties",
    4 => "Content items",
    5 => "Specialists",
    6 => "Clinics",
    7 => "Areas of practice",
    8 => "Feedback items",
  }
  
  def type
    REPORT::LEVEL_HASH[level_mask]
  end
  
  LEVEL_HASH = {
    1 => "System wide",
    2 => "Divisional",
    3 => "City",
  }
  
  def level
    REPORT::LEVEL_HASH[level_mask]
  end
  
  TIME_FRAME_HASH = {
    1 => "Yesterday",
    2 => "Last week",
    3 => "Last month",
    4 => "Last year",
    5 => "All time",
    6 => "Custom range",
  }
  
  def time_frame
    REPORT::TIME_FRAME_HASH[time_frame_mask]
  end
  
end