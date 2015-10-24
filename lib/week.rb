class Week
  attr_reader :start_date, :end_date

  def self.for_interval(start_date, end_date)
    start_date.previous_monday.step(end_date.previous_monday, 7).map do |date|
      Week.new(date)
    end
  end

  def initialize(start_date)
    @start_date = start_date
    @end_date = start_date + 6.days
  end

  def label
    "#{start_date.strftime('%b %-d')} - #{end_date.strftime('%b %-d')}"
  end

  def eql?(other)
    return false unless other.is_a? Week
    self.start_date == other.start_date
  end

  def ==(other)
    self.eql? other
  end

  def hash
    start_date.hash
  end
end
