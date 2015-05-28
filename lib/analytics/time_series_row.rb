module Analytics
  class TimeSeriesRow
    Metric::DIMENSIONS.each do |dimension|
      define_method dimension do
        dimensions[dimension]
      end
    end

    def initialize(cells, metric)
      @cells = cells
      @values = cells.inject({}) do |memo, cell|
        memo.merge({ cell.month_stamp => cell.send(metric) })
      end
    end

    def dimensions
      @dimensions ||= @cells.
        first.
        attributes.
        slice(*Metric::DIMENSIONS.map(&:to_s))
    end

    def [](month)
      values[month.to_i]
    end

    private

    attr_reader :cells, :values

  end
end
