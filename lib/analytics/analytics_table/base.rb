module Analytics
  module AnalyticsTable
    class Base < HashTable
      def search(query)
        rows.select { |row| row.lazy_match? query }
      end
    end
  end
end
