module Analytics
  class AnalyticsTable < HashTable
    attr_reader :metric, :min_sessions, :dimensions

    def initialize(rows, options)
      super(rows)
      @metric = options[:metric]
      @min_sessions = options[:min_sessions]
      @dimensions = options[:dimensions]
    end

    def search(query)
      result = rows.select { |row| row.lazy_match? query }

      AnalyticsTable.new(result)
    end

    def exists(key)
      result = rows.reject { |row| row[key].nil? }

      AnalyticsTable.new(result)
    end
    alias_method :breakdown_by, :exists
  end
end
