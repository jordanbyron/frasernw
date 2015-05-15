# Standard set of stats queries
class StatsReporter
  # requires at least start date and end date
  def self.full_users_breakdown(options)
    response = AnalyticsApiAdapter.get({
      metrics: [:pageviews, :sessions],
      dimensions: [:user_id, :user_type_key, :division_id]
    }.merge(options))
  end

  def self.divisions(options)
  end

  def self.account_types(options)
  end

  # 'visits'
  def self.sessions(options)
    AnalyticsApiAdapter.get({
      metrics: [:sessions],
    }.merge(options))
  end

  def self.page_views(options)
    AnalyticsApiAdapter.get({
      metrics: [:page_views],
    }.merge(options))
  end
end
