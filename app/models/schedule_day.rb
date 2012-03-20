class ScheduleDay < ActiveRecord::Base
  attr_accessible :scheduled, :from, :to
  has_one :schedule
  has_paper_trail
end
