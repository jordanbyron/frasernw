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

  include PaperTrailable

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

    [[monday, "Monday"], [tuesday, "Tuesday"], [wednesday, "Wednesday"], [thursday, "Thursday"], [friday, "Friday"], [saturday, "Saturday"], [sunday, "Sunday"]].each do |var|
      day = var.first
      day_name = var.second
      if day.scheduled? && day.time?
        output << "#{day_name} #{day.time}"
      elsif day.scheduled?
        output << day_name
      end
    end

    return output
  end

  DAY_HASH = {
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday",
    7 => "Sunday",
  }

  def collapsed_days_and_hours

    collapsed = {}

    [[monday, 1], [tuesday, 2], [wednesday, 3], [thursday, 4], [friday, 5], [saturday, 6], [sunday, 7]].each do |var|
      day = var.first
      day_id = var.second
      next if !day.scheduled?
      index = day.time? ? day.time : -1
      collapsed[index] = [collapsed[index], day_id].flatten.compact
    end

    output = []

    collapsed.each do |hours, day_ids|
      #difference between each day and the next. If it's all 1's (except the last element, where we wrapped) then we have consecutive days.
      consecutive = true
      day_ids.zip(day_ids.rotate).map { |x, y| y - x }.take( day_ids.size - 1 ).map{ |diff| consecutive &= (diff == 1) }

      #map our days to a sentence
      days = day_ids.map{ |id| DAY_HASH[id] }.to_sentence

      if day_ids.length >= 3 && consecutive
        days = "#{DAY_HASH[day_ids.first]} - #{DAY_HASH[day_ids.last]}"
      end

      if hours != -1
        output << "#{days}: #{hours}"
        else
        output << "#{days}"
      end
    end

    return output
  end

  def collapsed_days_and_hours_and_breaks

    collapsed = {}

    [[monday, 1], [tuesday, 2], [wednesday, 3], [thursday, 4], [friday, 5], [saturday, 6], [sunday, 7]].each do |var|
      day = var.first
      day_id = var.second
      next if !day.scheduled?
      index = (day.time? && day.break?) ? "#{day.time} (closed for lunch from #{day.break})" : (day.time? ? day.time : -1)
      collapsed[index] = [collapsed[index], day_id].flatten.compact
    end

    output = []

    collapsed.each do |hours_and_breaks, day_ids|
      #difference between each day and the next. If it's all 1's (except the last element, where we wrapped) then we have consecutive days.
      consecutive = true
      day_ids.zip(day_ids.rotate).map { |x, y| y - x }.take( day_ids.size - 1 ).map{ |diff| consecutive &= (diff == 1) }

      #map our days to a sentence
      days = day_ids.map{ |id| DAY_HASH[id] }.to_sentence

      if day_ids.length >= 3 && consecutive
        days = "#{DAY_HASH[day_ids.first]} - #{DAY_HASH[day_ids.last]}"
      end

      if hours_and_breaks != -1
        output << "#{days}: #{hours_and_breaks}"
      else
        output << "#{days}"
      end
    end

    return output
  end
end
