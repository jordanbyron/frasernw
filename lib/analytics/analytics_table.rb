module Analytics
  class AnalyticsTable < HashTable
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
