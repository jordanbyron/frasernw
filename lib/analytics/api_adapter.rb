# Handles construction of request params from simple query api and parsing of responses
module Analytics
  class ApiAdapter

    PROFILE_IDS_QUERY_PARAM = "ga:61207403"

    # example params
    # {
    #   start_date: <dateobj>
    #   end_date:   <dateobj>
    #   metrics:    "ga:pageviews"
    # }

    def self.get(query_params)
      response = Analytics::ApiClient.execute! construct_query(query_params)

      parse_response response
    end

    def self.user_type_keys
      self.user_type_hash.keys
    end

    def self.user_type_hash
      User::TYPE_HASH.merge(
        -1 => "Bounced",
        0 => "Admin"
      )
    end

    def self.user_type_from_key(key)
      self.user_type_hash[key.to_i]
    end

    private

    def self.construct_query(query_params)
      query = {
        :api_method => analytics.data.ga.get,
        :parameters => {
          "ids" => PROFILE_IDS_QUERY_PARAM,
          "start-date" => format_date(query_params[:start_date]),
          "end-date"   => format_date(query_params[:end_date]),
          "metrics"    => format_metrics(query_params[:metrics])
        }
      }

      if query_params[:dimensions].present?
        query[:parameters]["dimensions"] =
          format_dimensions(query_params[:dimensions])
      end

      if query_params[:filters].present?
        query[:parameters]["filters"] =
          format_filters(query_params[:filters])
      end

      query
    end

    METRICS = {
      page_views: "ga:pageviews",
      sessions: "ga:sessions",
      average_page_view_duration: "ga:avgTimeOnPage",
      average_session_duration: "ga:avgSessionDuration"
    }
    def self.format_metrics(metrics)
      metrics.map do |elem|
        METRICS[elem]
      end.join(",")
    end

    DIMENSIONS = {
      user_id: "ga:customVarValue1",
      user_type_key: "ga:customVarValue2",
      division_id: "ga:customVarValue3",
      page_path: "ga:pagePath"
    }
    def self.format_dimensions(dimensions)
      dimensions.map do |elem|
        DIMENSIONS[elem]
      end.join(",")
    end

    def self.format_filters(filters)
      filters.map do |key, value|
        "#{DIMENSIONS[key]}==#{value.to_s}"
      end.join(";")
    end

    def self.format_date(date)
      date.strftime("%F")
    end

    def self.analytics
      Analytics::ApiClient.discovered_api
    end

    # returns an array of hashes with symbol keys (column name)
    # and int values
    # [{ user_id: "1", sessions: "2" }]
    def self.parse_response(response)
      adapter_column_names = METRICS.merge(DIMENSIONS)
      response_column_names = response.data.column_headers.map(&:name)

      response.data.rows.map do |row|
        response_column_names.each_with_index.reduce({}) do |memo, (column_name, index)|
          memo.merge({ adapter_column_names.key(column_name) => row[index] })
        end
      end
    end
  end
end
