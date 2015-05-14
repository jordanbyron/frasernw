# Handles construction of request params and parsing of responses
class AnalyticsApiAdapter

  PROFILE_IDS_QUERY_PARAM = "ga:61207403"

  # example params
  # {
  #   start_date: <dateobj>
  #   end_date:   <dateobj>
  #   metrics:    "ga:pageviews"
  # }

  def self.get(query_params)
    response = AnalyticsApiClient.execute! construct_query(query_params)

    parse_response response
  end

  def self.construct_query(query_params)
    query = {
      api_method: analytics.data.ga.get,
      parameters: {
        "ids" => PROFILE_IDS_QUERY_PARAM,
        "start-date" => format_date(query_params[:start_date]),
        "end-date"   => format_date(query_params[:end_date]),
        "metrics"    => query_params[:metrics]
      }
    }

    [:dimensions, :filters].each do |optional_param|
      if query_params[optional_param].present?
        query[:parameters][optional_param.to_s] = query_params[optional_param]
      end
    end

    query
  end

  def self.format_date(date)
    date.strftime("%F")
  end

  def self.analytics
    AnalyticsApiClient.discovered_api
  end

  # returns simple array of hashes
  # [{"ga_key_1" => "value", "ga_key_2" => "value"}]
  def self.parse_response(response)
    column_names = response.data.column_headers.map(&:name)

    response.data.rows.map do |row|
      column_names.each_with_index.reduce({}) do |memo, (column_name, index)|
        memo.merge({ column_name => row[index] })
      end
    end
  end
end
