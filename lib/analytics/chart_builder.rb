module Analytics
  # takes params passed to the html controller action and produces a chart config for the highcharts instance itself and its controls
  class ChartBuilder

    def initialize(params)
      @params = params
    end

    def exec
      {
        metric: metric,
        dimensions: dimensions,
        months: months
      }
    end

    def metric
      :page_views
    end

    def dimensions
      [
        {
          label: "Division",
          identifier: :division_id,
          values: Division.all.map {|division| {label: division.name, value: division.id }}
        }
      ]
    end

    def months
      Month.for_interval(start_month, end_month).map(&:name)
    end

    def start_month
      Month.new(2014, 4)
    end

    def end_month
      Month.prev
    end
  end
end
