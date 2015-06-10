module Analytics
  class QueryScope
    attr_reader :table, :scope

    def initialize(table, scope)
      @table = table
      @scope = scope
    end

    def aggregate(query)
      table.aggregate(query.merge(scope))
    end

    def all
      table.aggregate(scope)
    end
  end
end
