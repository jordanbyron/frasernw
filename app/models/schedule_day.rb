class ScheduleDay < ActiveRecord::Base
  attr_accessible :scheduled, :from, :to
  has_one :schedule
  has_paper_trail
  
  def time?
    from.hour != 0 || from.min != 0 || to.hour != 0 || to.min != 0
  end
  
  def time
    "#{from.to_s(:schedule_time)} - #{to.to_s(:schedule_time)}"
  end
end
