class AnalyticsChartMonths < ServiceObject
  def call
    Month.for_interval(
      Month.new(2014, 4),
      Month.current
    ).map do |month|
      [
        month.friendly_name,
        month.to_i
      ]
    end
  end
end
