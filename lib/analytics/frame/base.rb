module Analytics
  # For a single time period (frame)

  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions
  module Frame
    class Base
      attr_reader :metric, :options

      def initialize(metric, options)
        @metric = metric
        @options = options
      end
    end
  end
end
