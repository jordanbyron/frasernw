module Analytics
  module Filter
    class Search < Base
      def exec
        AnalyticsTable.new(
          table.search(filter)
        )
      end
    end
  end
end
