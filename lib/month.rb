class Month

  def self.prev
    new(
      Date.today.year,
      (Date.today.month - 1)
    )
  end

  # the current month
  def self.current
    new(
      Date.today.year,
      Date.today.month
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
