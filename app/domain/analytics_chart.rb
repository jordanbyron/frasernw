class AnalyticsChart < ServiceObject
  attribute :start_month_key
  attribute :end_month_key
  attribute :metric
  attribute :divisions
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :user_type_key
  attribute :period_type, String

  METRICS = [
    :page_views,
    :sessions,
    :user_ids
  ]

  PERIOD_TYPES = [
    "month",
    "week"
  ]

  def self.period_type_options
    PERIOD_TYPES.map{|period_type| [ period_type.capitalize, period_type ]}
  end

  def self.regenerate_all
    METRICS.each do |metric|
      PERIOD_TYPES.each do |period_type|
        regenerate(metric, period_type)
      end
    end
  end

  def self.regenerate(metric, period_type)
    call(
      start_month_key: 201401,
      end_month_key: Month.current.to_i,
      metric: metric,
      period_type: period_type,
      divisions: Division.except_provincial,
      force: true
    )
  end

  def call
    {
      title: {
        text: "Pathways #{metric_label}",
        x: -50
      },
      subtitle: {
        text: "#{start_date.strftime("%b %d %Y")} - #{end_date.strftime("%b %d %Y")}",
        x: -50
      },
      xAxis: {
        title: {
          text: "#{period_type.capitalize} Starting On"
        },
        labels: {
          staggerLines: 1,
          rotation: -45,
          format: "{value:%b %e, %Y}"
        },
        type: "datetime"
      },
      yAxis: {
        title: {
          text: "#{metric_label}/ #{period_type.capitalize}"
        },
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }],
        min: 0
      },
      legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle',
        borderWidth: 0
      },
      plotOptions: {
        series: {
          marker: {
            enabled: false
          }
        }
      },
      credits: {
        enabled: false,
      },
      series: series
    }
  end

  private

  def series
    (divisions.map(&:id) << 0).map do |division_id|
      {
        name: (division_id == 0 ? "All Divisions" : Division.find(division_id).name),
        data: periods.map do |period|
          [
            (period.start_date.at_midnight.to_i*1000),
            division_period_data(period, division_id)[user_type_key]
          ]
        end
      }
    end
  end

  def division_period_data(period, division_id)
    Rails.cache.fetch(
      "non_admin_#{metric.to_s}:#{period_type}:#{period.start_date.to_s}:#{division_id}",
      force: force
    ) do
      division_rows = filter_by_division(period_data(period), division_id)

      User::TYPES.keys.map do |key|
        [
          key,
          metric_from_rows(division_rows.select{|row| row[:user_type_key].to_i == key })
        ]
      end.to_h.merge(
        -1 => metric_from_rows(
          division_rows.select{|row| User::TYPES.include?(row[:user_type_key].to_i) }
        )
      )
    end
  end

  def period_data(period)
    @periods_data ||= {}

    if @periods_data[period].nil?
      @periods_data[period] = Analytics::ApiAdapter.get(
        start_date: period.start_date,
        end_date: period.end_date,
        metrics: [:page_views, :sessions],
        dimensions: query_dimensions
      )
    end

    @periods_data[period]
  end

  def query_dimensions
    if metric == :user_ids
      [:division_id, :user_type_key, :user_id]
    else
      [:division_id, :user_type_key]
    end
  end

  def metric_from_rows(rows)
    if metric == :user_ids
      rows.group_by{|row| row[:user_id]}.keys.count
    else
      rows.map{|row| row[metric]}.map(&:to_i).sum
    end
  end

  def filter_by_division(rows, division_id)
    if division_id == 0
      rows
    else
      rows.select{|row| row[:division_id] == division_id.to_s }
    end
  end

  def periods
    @periods ||= period_type.
      classify.
      constantize.
      for_interval(start_date, end_date).reject do |period|

      period.end_date > Date.current
    end
  end

  def metric_label
    "#{metric.to_s.split("_").map(&:capitalize).join(" ")}"
  end

  def start_date
    @start_date ||= Month.from_i(start_month_key).start_date
  end

  def end_date
    @end_date ||= Month.from_i(end_month_key).end_date
  end
end
