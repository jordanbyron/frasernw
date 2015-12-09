class Month
  def self.prev
    new(
      Date.current.year,
      (Date.current.month - 1)
    )
  end

  # the current month
  def self.current
    new(
      Date.current.year,
      Date.current.month
    )
  end

  def self.for_interval(first, second)
    (first.year..second.year).inject([]) do |memo, year|
      if year == first.year && year == second.year
        memo + (first.month..second.month).to_a.map {|month| new(year, month) }
      elsif year == first.year
        memo + (first.month..12).to_a.map {|month| new(year, month) }
      elsif year == second.year
        memo + (1..second.month).to_a.map {|month| new(year, month) }
      else
        memo + (1..12).to_a.map {|month| new(year, month) }
      end
    end
  end

  # "2011-1"
  def self.from_string(str)
    year_month = str.split("-")

    new(
      year_month[0].to_i,
      year_month[1].to_i
    )
  end

  attr_reader :year, :month

  def initialize(year, month)
    @year  = year
    @month = month
  end

  def first_week
    Week.new(start_date.previous_monday)
  end

  def last_week
    Week.new(end_date.previous_monday)
  end

  def weeks
    Week.for_interval(start_date, end_date)
  end

  def to_i
    start_date.strftime("%Y%m").to_i
  end

  def self.from_i(integer)
    year = integer.to_s[0..3].to_i
    month = integer.to_s[4..5].to_i

    Month.new(year, month)
  end

  def friendly_name
    start_date.strftime("%b %Y")
  end

  def full_name
    start_date.strftime("%B %Y")
  end

  def name
    start_date.strftime("%m-%Y")
  end

  def to_cache_key
    start_date.strftime("%m-%Y")
  end

  def eql?(other)
    return false unless other.is_a? Month
    self.month == other.month && self.year == other.year
  end

  def ==(other)
    self.eql? other
  end

  def hash
    [month, year].hash
  end

  def start_date
    Date.civil(year, month, 1)
  end

  def end_date
    Date.civil(year, month, -1)
  end
end
