class Report < ActiveRecord::Base
  
  attr_accessible :name, :type_mask, :level_mask, :division_id, :city_id, :user_type_mask, :time_frame_mask, :start_date, :end_date, :by_user, :by_pageview, :only_shared_care
  
  belongs_to :division
  belongs_to :city
  
  module ReportType
    PAGE_VIEWS = 1
    USERS = 2
    SPECIALTIES = 3
    CONTENT_ITEMS = 4
    SPECIALISTS = 5
    CLINICS = 6
    AREAS_OF_PRACTICE = 7
    FEEDBACK_ITEMS = 8
    SPECIALIST_CONTACT_HISTORY = 9
  end
  
  TYPE_HASH = {
    ReportType::PAGE_VIEWS => "Page views",
    ReportType::CONTENT_ITEMS => "Content items",
    ReportType::SPECIALIST_CONTACT_HISTORY => "Specialist contact history",
  }
  
  def type
    Report::TYPE_HASH[type_mask]
  end
  
  USER_TYPE_HASH = {-1 => 'All Non-Admin Users', 0 => 'All Users' }.merge(User::TYPE_HASH)
  
  def user_type
    Report::USER_TYPE_HASH[user_type_mask]
  end

  module ReportLevel
    SYSTEM_WIDE = 1
    DIVISIONAL = 2
  end
  
  LEVEL_HASH = {
    ReportLevel::SYSTEM_WIDE => "System-wide",
    ReportLevel::DIVISIONAL => "Divisional",
  }
  
  def level
    Report::LEVEL_HASH[level_mask]
  end

  def level_name
    if divisional?
      return Division.find(division_id).name
    else
      return level
    end
  end
  
  def divisional?
    LEVEL_HASH[level_mask] == ReportLevel::DIVISIONAL
  end

  module TimeFrame
    YESTERDAY = 1
    LAST_WEEK = 2
    LAST_MONTH = 3
    LAST_YEAR = 4
    ALL_TIME = 5
    CUSTOM_RANGE= 6
  end

  TIME_FRAME_HASH = {
    TimeFrame::YESTERDAY => "Yesterday",
    TimeFrame::LAST_WEEK => "Last week",
    TimeFrame::LAST_MONTH => "Last month",
    TimeFrame::LAST_YEAR => "Last year",
    TimeFrame::ALL_TIME => "All time",
    TimeFrame::CUSTOM_RANGE => "Custom range",
  }
  
  def time_frame
    Report::TIME_FRAME_HASH[time_frame_mask]
  end
  
end
