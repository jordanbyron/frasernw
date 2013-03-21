class Report < ActiveRecord::Base
  
  attr_accessible :name, :type_mask, :level_mask, :division_id, :city_id, :user_type_mask, :time_frame_mask, :start_date, :end_date, :by_user, :by_pageview, :only_shared_care
  
  belongs_to :division
  belongs_to :city
  
  TYPE_HASH = {
    1 => "General page views",
    2 => "Users",
    3 => "Specialties",
    4 => "Content items",
    5 => "Specialists",
    6 => "Clinics",
    7 => "Areas of practice",
    8 => "Feedback items",
    9 => "Specialist contact history",
  }
  
  def type
    Report::TYPE_HASH[type_mask]
  end
  
  USER_TYPE_HASH = {-1 => 'All Non-Admin Users', 0 => 'All Users' }.merge(User::TYPE_HASH)
  
  def user_type
    Report::USER_TYPE_HASH[user_type_mask]
  end
  
  LEVEL_HASH = {
    1 => "System-wide",
    2 => "Divisional",
  }
  
  def level
    Report::LEVEL_HASH[level_mask]
  end
  
  def level_divisional?
    LEVEL_HASH[level_mask] == 2
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
