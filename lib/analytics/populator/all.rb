module Analytics
  module Populator
    class All
      # metrics and the dimensions we want to gather for them
      CONFIGS = [
        {
          metric: :visitor_accounts,
          dimensions: [ :division_id, :user_type_key, :page_path ]
        },
        {
          metric: :visitor_accounts,
          dimensions: [:division_id, :user_type_key],
          min_sessions: 5
        },
        {
          metric: :visitor_accounts,
          dimensions: [:division_id, :user_type_key],
          min_sessions: 10
        },
        {
          metric: :page_views,
          dimensions: [:division_id, :user_type_key, :page_path]
        },
        {
          metric: :sessions,
          dimensions: [:division_id, :user_type_key]
        },
        {
          metric: :average_session_duration,
          dimensions: [:division_id, :user_type_key]
        },
        {
          metric: :average_page_view_duration,
          dimensions: [:division_id, :user_type_key]
        }
      ]

      def self.exec
        CONFIGS.each do |config|
          Analytics::Populator::TimeSeries.exec(config)
        end
      end
    end
  end
end
