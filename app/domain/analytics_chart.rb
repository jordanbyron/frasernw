class AnalyticsChart < ServiceObject
  attribute :start_month_key
  attribute :end_month_key
  attribute :metric
  attribute :divisions
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :user_type_key

  SUPPORTED_METRICS = [
    :page_views,
    :sessions,
    :user_ids
  ]

  def self.regenerate_all
    SUPPORTED_METRICS.each do |metric|
      regenerate(metric)
    end
  end

  def self.regenerate(metric)
    call(
      start_date: Month.new(2014, 1).start_date,
      end_date: Date.current,
      metric: metric,
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
          text: "Week Starting On"
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
          text: "#{metric_label}/ Week"
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
        data: weeks.map do |week|
          [
            (week.start_date.at_midnight.to_i*1000),
            division_week_data(week, division_id)[user_type_key]
          ]
        end
      }
    end
  end

  def division_week_data(week, division_id)
    Rails.cache.fetch(
      "non_admin_#{metric.to_s}:#{week.start_date.to_s}:#{division_id}",
      force: force
    ) do
      division_rows = filter_by_division(week_data(week), division_id)

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

  def week_data(week)
    @weeks_data ||= Hash.new do |hsh, key|
      hsh[key] = Analytics::ApiAdapter.get(
        start_date: week.start_date,
        end_date: week.end_date,
        metrics: [:page_views, :sessions],
        dimensions: query_dimensions
      )
    end

    @weeks_data[week]
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

  def weeks
    @weeks = Week.for_interval(start_date, end_date).reject do |week|
      week.end_date > Date.current
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
