class AnalyticsChart

  include ServiceObject.exec_with_args(:start_date, :end_date, :metric, :divisions, :force)

  SUPPORTED_METRICS = [
    :page_views,
    :sessions
  ]

  def self.generate_full_cache
    SUPPORTED_METRICS.each do |metric|
      exec(
        start_date: Month.new(2014, 1).start_date,
        end_date: Date.today,
        metric: metric,
        divisions: Division.standard,
        force: true
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

  def data
    @data ||= weeks.inject({}) do |memo, week|
      memo.merge(
        week => data_for_week(week)
      )
    end
  end

  def data_for_week(week)
    raw = Analytics::ApiAdapter.get(
      start_date: week.start_date,
      end_date: week.end_date,
      metrics: [metric],
      dimensions: [:division_id, :user_type_key]
    )

    (divisions.map(&:id) << 0).inject({}) do |memo, division_id|
      result = raw.select do |row|
        filter_by_division(row, division_id) &&
          User::TYPE_HASH.keys.include?(row[:user_type_key].to_i)
      end.map{|row| row[metric]}.map(&:to_i).sum

      memo.merge(division_id => result)
    end
  end

  def filter_by_division(row, division_id)
    if division_id == 0
      return true
    else
      return  row[:division_id] == division_id.to_s
    end
  end

  def global_series
    {
      name: "All Divisions",
      data: weeks.map do |week|
        [
          (week.start_date.at_midnight.to_i*1000),
          Rails.cache.fetch("non_admin_#{metric.to_s}:#{week.start_date.to_s}:global", force: force) do
            data[week][0]
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
          Rails.cache.fetch("non_admin_#{metric.to_s}:#{week.start_date.to_s}:#{division.id}", force: force) do
            data[week][division.id]
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
    @weeks = Week.for_interval(start_date, end_date).reject do |week|
      week.end_date > Date.today
    end
  end

  def categories
    weeks.map(&:label)
  end

  def metric_label
    "#{metric.to_s.split("_").map(&:capitalize).join(" ")}"
  end
end
