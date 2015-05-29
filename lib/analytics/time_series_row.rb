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

    def first_record_attributes
      HashWithIndifferentAccess.new(@cells.first.attributes)
    end

    def dimensions
      @dimensions ||= first_record_attributes.
        slice(*Metric::DIMENSIONS).
        symbolize_keys
    end

    def safe_val(month)
      self[month] || 0
    end

    def [](month)
      values[month.to_i]
    end

    private

    attr_reader :cells, :values
  end
end
