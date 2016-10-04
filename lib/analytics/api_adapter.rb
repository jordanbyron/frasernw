# V3 API reference:
# https://developers.google.com/analytics/devguides/reporting/core/v3/reference

# Handles construction of request params from simple query api and parsing of responses
module Analytics
  class ApiAdapter
    PROFILE_IDS_QUERY_PARAM = "ga:61207403"
    MAX_RESULTS = 10000

    # example params
    # {
    #   start_date: <dateobj>
    #   end_date:   <dateobj>
    #   metrics:    "ga:pageviews"
    # }

    def self.get(query_params, options = {})
      options[:batch] = true if options[:batch].nil?

      query_params[:page] ||= 1

      response = Analytics::ApiClient.execute! construct_query(query_params)
      puts "got response"
      wrapped_response = Analytics::Response.new(response)

      if options[:batch] && wrapped_response.max_reached?
        Analytics::BatchHandler.new(wrapped_response, query_params).exec
      else
        wrapped_response.parse_rows
      end
    end

    def self.snoop_browser(user_id)
      Analytics::ApiAdapter.get(
        metrics: [:page_views],
        dimensions: [:browser, :browser_version],
        filters: {user_id: user_id},
        start_date: (Date.today - 3.days),
        end_date: (Date.today + 1.day)
      )
    end

    def self.user_type_keys
      self.user_type_hash.keys
    end

    def self.user_type_hash
      User::TYPES.merge(
        -1 => "Bounced",
        0 => "Admin"
      )
    end

    private


    # TODO extract to own object
    def self.construct_query(query_params)
      query = {
        :api_method => analytics.data.ga.get,
        :parameters => {
          "ids" => PROFILE_IDS_QUERY_PARAM,
          "start-date"  => format_date(query_params[:start_date]),
          "end-date"    => format_date(query_params[:end_date]),
          "metrics"     => format_metrics(query_params[:metrics]),
          "start-index" => start_index(query_params[:page]),
          "max-results" => MAX_RESULTS.to_s
        }
      }

      if query_params[:dimensions].try(:any?)
        query[:parameters]["dimensions"] =
          format_dimensions(query_params[:dimensions])
      end

      if query_params[:filters].present?
        query[:parameters]["filters"] =
          format_filters(query_params[:filters], "==")
      end

      # option for greater flexibility
      if query_params[:filter_literal].present?
        query[:parameters]["filters"] = query_params[:filter_literal]
      end

      puts query

      query
    end

    METRICS = {
      page_views: "ga:pageviews",
      sessions: "ga:sessions",
      average_page_view_duration: "ga:avgTimeOnPage",
      average_session_duration: "ga:avgSessionDuration",
      total_events: "ga:totalEvents"
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
      page_path: "ga:pagePath",
      event_category: "ga:eventCategory",
      event_label: "ga:eventLabel",
      event_action: "ga:eventAction",
      browser: "ga:browser",
      browser_version: "ga:browserVersion"
    }
    def self.format_dimensions(dimensions)
      dimensions.map do |elem|
        DIMENSIONS[elem]
      end.join(",")
    end

    # ';' is 'AND'
    def self.format_filters(filters, operator)
      filters.map do |key, value|
        "#{DIMENSIONS[key]}#{operator}#{value.to_s}"
      end.join(";")
    end

    def self.start_index(current_page)
      ((current_page - 1) * MAX_RESULTS) + 1
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
  end
end
