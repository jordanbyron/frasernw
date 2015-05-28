module Analytics
  # Aggregates a bunch of month cells to a time series row for a given metric
  class CellAggregator
    def self.time_series(cells, metric)
      cells.subsets do |cell|
        Metric::DIMENSIONS.map { |dimension| cell.send(dimension) }
      end.map do |set|
        TimeSeriesRow.new(set, metric)
      end
    end
  end
end
