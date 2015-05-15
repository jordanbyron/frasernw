# Standard set of stats queries
class StatsReporter
  # requires at least start date and end date
  def self.users(options)
    response = AnalyticsApiAdapter.get({
      metrics: [:page_views, :sessions],
      dimensions: [:user_id, :user_type_key, :division_id]
    }.merge(options))
  end

  def self.user_types(options)
    response = AnalyticsApiAdapter.get({
      metrics: [:page_views, :sessions],
      dimensions: [:user_type_key]
    }.merge(options))
  end

  def self.total_users(options)
    AnalyticsApiAdapter.get({
      metrics: [:page_views],
      dimensions: [:user_id]
    }.merge(options)).count
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
