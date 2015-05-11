class Month
  attr_reader :year, :month_number

  def initialize(year, month_number)
    @month_number = month_number
    @year         = year
  end

  def start_date
    Date.civil(year, month_number, 1)
  end

  def end_date
    Date.civil(year, month_number, -1)
  end
end
