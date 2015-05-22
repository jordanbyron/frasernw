module Reporter
  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions
  module ByDivisionAndUserType
    def self.time_series(metric, options)
      if [:users, :users_min_5_sessions, :users_min_10_sessions].include? metric
        Users.time_series(metric, options)
      else
        Base.time_series(metric, options)
      end
    end
  end
end
