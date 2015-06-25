module Analytics
  # parses GA response
  # # returns an array of hashes with symbol keys (column name)
  # and int values
  # [{ user_id: "1", sessions: "2" }]
  class Response
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def total_results
      response.data.total_results
    end

    def pages
      ( total_results.to_f / Analytics::ApiAdapter::MAX_RESULTS.to_f ).ceil
    end

    def max_reached?
      response.data.total_results > Analytics::ApiAdapter::MAX_RESULTS
    end

    def parse_rows
      response.data.rows.map do |row|
        parse_row(row)
      end
    end

    def parse_row(row)
      response_column_names.each_with_index.reduce({}) do |memo, (column_name, index)|
        memo.merge({ adapter_column_names.key(column_name) => row[index] })
      end
    end

    def adapter_column_names
      @adapter_column_names ||= Analytics::ApiAdapter::METRICS.merge(
        Analytics::ApiAdapter::DIMENSIONS
      )
    end

    def response_column_names
      @response_column_names ||= response.data.column_headers.map(&:name)
    end
  end
end
