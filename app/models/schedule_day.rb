class ScheduleDay < ActiveRecord::Base
  attr_accessible :scheduled, :from, :to, :break_from, :break_to
  has_one :schedule
  has_paper_trail
  
  def time?
    from.present? && to.present? && (from.hour != 0 || from.min != 0 || to.hour != 0 || to.min != 0)
  end
  
  def break?
    break_from.present? && break_to.present? && (break_from.hour != 0 || break_from.min != 0 || break_to.hour != 0 || break_to.min != 0)
  end
  
  def time
    "#{from.to_s(:schedule_time)} - #{to.to_s(:schedule_time)}"
  end
  
  def break
    "#{break_from.to_s(:schedule_time)} - #{break_to.to_s(:schedule_time)}"
  end
end
