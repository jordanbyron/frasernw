# Handles setup and authorization of google's api client
module Analytics
  class ApiClient
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
      begin
        client.execute! query
      rescue Google::APIClient::AuthorizationError
        authorize client
        client.execute! query
      end
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

    def authorize(client)
      client.authorization = authorization
      client.authorization.fetch_access_token!

      client
    end

    def client
      @client ||= authorize(Google::APIClient.new(
        :application_name => 'Pathways',
        :application_version => '1.0.0'
      ))
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
      @key ||= OpenSSL::PKey::RSA.new ENV['GOOGLE_OAUTH_P12_KEY'], 'notasecret'
    end
  end
end
