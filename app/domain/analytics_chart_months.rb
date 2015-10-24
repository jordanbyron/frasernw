class AnalyticsChartMonths
  include ServiceObject.exec_with_args

  def exec
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

  def self.parse(params)
    {
      start_date: Month.from_i(params[:start_month]).start_date,
      end_date: Month.from_i(params[:end_month]).end_date
    }
  end
end
