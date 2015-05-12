require 'google/api_client'
require 'google/api_client/auth/installed_app'

# Initialize the client.
client = Google::APIClient.new(
  :application_name => 'Example Ruby application',
  :application_version => '1.0.0'
)

# Initialize Google+ API. Note this will make a request to the
# discovery service every time, so be sure to use serialization
# in your production code. Check the samples for more details.
analytics = client.discovered_api('analytics', 'v3')

key = Google::APIClient::KeyUtils.load_from_pkcs12('config/google_oauth.p12', 'notasecret')

client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics',
  :issuer => '955822272861-lifnjlkoavjjrd9njcivh59i39btdue2@developer.gserviceaccount.com',
  :signing_key => key
)

client.authorization.fetch_access_token!

result = client.execute!({
  :api_method => analytics.data.ga.get,
  :parameters => {
    "ids" => "ga:61207403",
    "start-date" => "7daysAgo",
    "end-date" => "today",
    "metrics" => "ga:pageviews"
  }
})

puts result.data.to_h
