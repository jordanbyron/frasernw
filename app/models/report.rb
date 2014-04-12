class Report < ActiveRecord::Base
  
  attr_accessible :name, :type_mask, :level_mask, :division_id, :city_id, :user_type_mask, :time_frame_mask, :start_date, :end_date, :by_user, :by_pageview, :only_shared_care
  
  belongs_to :division
  belongs_to :city
  
  module ReportType
    PAGE_VIEWS = 1
    USERS = 2
    SPECIALTIES = 3
    CONTENT_ITEMS = 4
    SPECIALIST_WAIT_TIMES = 5
    CLINIC_WAIT_TIMES = 6
    AREAS_OF_PRACTICE = 7
    FEEDBACK_ITEMS = 8
    SPECIALIST_CONTACT_HISTORY = 9
    ENTITY_STATS = 10
  end
  
  TYPE_HASH = {
    ReportType::PAGE_VIEWS => "Page views",
    ReportType::CONTENT_ITEMS => "Content items",
    ReportType::SPECIALIST_WAIT_TIMES => "Specialist wait times",
    ReportType::CLINIC_WAIT_TIMES => "Clinic wait times",
    ReportType::SPECIALIST_CONTACT_HISTORY => "Specialist contact history",
    ReportType::ENTITY_STATS => "Entity Statistics",
  }
  
  def type
    Report::TYPE_HASH[type_mask]
  end
  
  USER_TYPE_HASH = {-1 => 'All Non-Admin Users', 0 => 'All Users' }.merge(User::TYPE_HASH)
  
  def user_type
    if [ReportType::SPECIALIST_CONTACT_HISTORY, ReportType::SPECIALIST_WAIT_TIMES, ReportType::CLINIC_WAIT_TIMES, ReportType::ENTITY_STATS].include? type_mask
      "N/A"
    else
      Report::USER_TYPE_HASH[user_type_mask]
    end
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
      Division.find(division_id).name
    else
      level
    end
  end
  
  def divisional?
    level_mask == ReportLevel::DIVISIONAL
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

  def time_frame_name
    if [ReportType::SPECIALIST_WAIT_TIMES, ReportType::CLINIC_WAIT_TIMES, ReportType::ENTITY_STATS].include? type_mask
      "N/A"
    elsif type_mask == ReportType::SPECIALIST_CONTACT_HISTORY
      TIME_FRAME_HASH[TimeFrame::ALL_TIME]
    elsif time_frame_mask == Report::TimeFrame::CUSTOM_RANGE
      "#{start_date} - #{end_date}"
    else
      time_frame
    end
  end
end
