class AnalyticsChart

  include ServiceObject.exec_with_args(:start_date, :end_date, :metric)

  SUPPORTED_METRICS = [
    :page_views,
    :sessions
  ]

  def self.generate_full_cache
    SUPPORTED_METRICS.each do |metric|
      exec(
        start_date: Month.new(2014, 1).start_date,
        end_date: Month.prev.end_date,
        metric: metric
      )
    end
  end

  def exec
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
          text: "Week"
        },
        labels: {
          staggerLines: 1,
          rotation: -45
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
        }]
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
      series: series
    }
  end

  private

  def divisional_data
    @divisional_data ||= weeks.inject({}) do |memo, week|
      memo.merge(
        week => divisional_data_for_week(week)
      )
    end
  end

  def divisional_data_for_week(week)
    raw = Analytics::ApiAdapter.get(
      start_date: week.start_date,
      end_date: week.end_date,
      metrics: [metric],
      dimensions: [:division_id, :user_type_key]
    )

    divisions.inject({}) do |memo, division|
      views = raw.select do |row|
        row[:division_id] == division.id.to_s &&
          User::TYPE_HASH.keys.include?(row[:user_type_key].to_i)
      end.map{|row| row[metric]}.map(&:to_i).sum

      memo.merge(division.id => views)
    end
  end

  def global_data(week)
    raw = Analytics::ApiAdapter.get(
      start_date: week.start_date,
      end_date: week.end_date,
      metrics: [metric],
      dimensions: [:user_type_key]
    )

    raw.select do |row|
      User::TYPE_HASH.keys.include?(row[:user_type_key].to_i)
    end.map{|row| row[metric]}.map(&:to_i).sum
  end

  def divisions
    Division.all.reject do |division|
      division.name == "Provincial" || division.name == "Vancouver (Hidden)"
    end
  end

  def global_series
    {
      name: "All Divisions",
      data: weeks.map do |week|
        [
          (week.start_date.at_midnight.to_i*1000),
          Rails.cache.fetch("non_admin_#{metric.to_s}:#{week.start_date.to_s}:global") do
            global_data(week)
          end
        ]
      end
    }
  end

  def divisional_series(division)
    {
      name: division.name,
      data: weeks.map do |week|
        [
          (week.start_date.at_midnight.to_i*1000),
          Rails.cache.fetch("non_admin_#{metric.to_s}:#{week.start_date.to_s}:#{division.id}") do
            divisional_data[week][division.id]
          end
        ]
      end
    }
  end

  def divisions_series
    divisions.map{ |division| divisional_series(division) }
  end

  def series
    divisions_series << global_series
  end

  def weeks
    @weeks = Week.for_interval(start_date, end_date)
  end

  def categories
    weeks.map(&:label)
  end

  def metric_label
    "#{metric.to_s.split("_").map(&:capitalize).join(" ")}"
  end
end
