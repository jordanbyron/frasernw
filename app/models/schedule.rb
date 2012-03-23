class Schedule < ActiveRecord::Base
  belongs_to :schedulable, :polymorphic => true
  
  belongs_to :monday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :monday
  
  belongs_to :tuesday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :tuesday
  
  belongs_to :wednesday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :wednesday
  
  belongs_to :thursday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :thursday
  
  belongs_to :friday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :friday
  
  belongs_to :saturday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :saturday
  
  belongs_to :sunday, :class_name => "ScheduleDay"
  accepts_nested_attributes_for :sunday
  
  has_paper_trail
  
  def scheduled?
    monday.scheduled || tuesday.scheduled || wednesday.scheduled || thursday.scheduled || friday.scheduled || saturday.scheduled || sunday.scheduled
  end
  
  def days
    output = []
    output << "Monday" if monday.scheduled
    output << "Tuesday" if tuesday.scheduled
    output << "Wednesday" if wednesday.scheduled
    output << "Thursday" if thursday.scheduled
    output << "Friday" if friday.scheduled
    output << "Saturday" if saturday.scheduled
    output << "Sunday" if sunday.scheduled
    return output
  end
  
  def days_and_hours
    output = []
    output << "Monday #{monday.from.to_s(:schedule_time)} - #{monday.to.to_s(:schedule_time)}" if monday.scheduled
    output << "Tuesday #{tuesday.from.to_s(:schedule_time)} - #{tuesday.to.to_s(:schedule_time)}" if tuesday.scheduled
    output << "Wednesday #{wednesday.from.to_s(:schedule_time)} - #{wednesday.to.to_s(:schedule_time)}" if wednesday.scheduled
    output << "Thursday #{thursday.from.to_s(:schedule_time)} - #{thursday.to.to_s(:schedule_time)}" if thursday.scheduled
    output << "Friday #{friday.from.to_s(:schedule_time)} - #{friday.to.to_s(:schedule_time)}" if friday.scheduled
    output << "Saturday #{saturday.from.to_s(:schedule_time)} - #{saturday.to.to_s(:schedule_time)}" if saturday.scheduled
    output << "Sunday #{sunday.from.to_s(:schedule_time)} - #{sunday.to.to_s(:schedule_time)}" if sunday.scheduled
    return output
  end
end
