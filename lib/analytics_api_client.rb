require 'google/api_client'
require 'google/api_client/auth/installed_app'

# Concrete Analytics API Client for this app
class AnalyticsApiClient
  KEY_PASS = 'notasecret'
  KEY_PATH = Rails.root.join('config', 'google_oauth.p12')

  PROFILE_IDS_QUERY_PARAM = "ga:61207403"

  # example query
  # {
  #   "api_method" => analytics.data.ga.get,
  #   "parameters" => {
  #     "ids" => "ga:61207403",
  #     "start-date" => "7daysAgo",
  #     "end-date" => "today",
  #     "metrics" => "ga:pageviews"
  #   }
  # }
  def self.execute!(query)
    instance.execute!(query)
  end

  def execute!(query)
    # attempt the query, resque from unauthorized, authorize, then try again
    authorized_client.execute! query
  end

  def self.discovered_api
    instance.analytics
  end

  def analytics
    @analytics ||= client.discovered_api('analytics', 'v3')
  end

  private

  def self.instance
    @@instance ||= new
  end

  def client
    @client ||= Google::APIClient.new(
      :application_name => 'Pathways',
      :application_version => '1.0.0'
    )
  end

  def authorized_client
    # TODO don't reauth every time

    client.tap do |client|
      client.authorization = authorization
      client.authorization.fetch_access_token!
    end
  end

  def authorization
    @authorization ||= Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience => 'https://accounts.google.com/o/oauth2/token',
      :scope => 'https://www.googleapis.com/auth/analytics',
      :issuer => '955822272861-lifnjlkoavjjrd9njcivh59i39btdue2@developer.gserviceaccount.com',
      :signing_key => key
    )
  end

  def key
    @key ||= Google::APIClient::KeyUtils.load_from_pkcs12(KEY_PATH, KEY_PASS)
  end
end
