module Analytics
  module Filter
    class PathMatch < Base
      def exec(table)
        new_rows = table.rows.select do |row|
          (row[:page_path] || "")[filter[:path_regexp]]
        end

        AnalyticsTable.new(new_rows)
      end
    end
  end
end
