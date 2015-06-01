module Analytics
  # for when we want to return the remaining pages of a result

  class BatchHandler
    attr_reader :response, :query_params

    def initialize(response, query_params)
      @response     = response
      @query_params = query_params
    end

    def exec
      puts "batching #{response.pages} page response"

      (2..response.pages).inject(original_rows) do |memo, page|
        new_memo = memo + Analytics::ApiAdapter.get(query(page), batch: false)

        puts "response has #{new_memo.count} rows"

        new_memo
      end
    end

    def query(current_page)
      query_params.merge(page: current_page)
    end

    def original_rows
      response.parse_rows
    end
  end
end
