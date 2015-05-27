module Analytics
  module Filter
    class Search < Base
      def exec(table)
        table.search(filter)
      end
    end
  end
end
