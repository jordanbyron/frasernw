module HerokuCloudBackup
  class << self
    def execute
      puts "Backing up last heroku backup to S3"

      backup = client.
        transfers.
        reject{|transfer| transfer[:to_type] == "pg_restore" }.
        first

      public_url = client.transfers_public_url(backup[:uuid])[:url]
      backup_created_at = DateTime.parse backup[:created_at]
      uri = URI(public_url)

      Net::HTTP.start(uri.host) do |http|
        resp = http.get(uri.path)
        Pathways::S3.
          bucket(:db_backups).
          objects["#{backup_created_at.strftime('%Y-%m-%d-%H%M%S')}.dump"].
          write(resp.body, acl: :private)
      end
    end

    def client
      @client ||= HerokuCloudBackup::PGApp.new(ENV["APP_NAME"])
    end
  end

  class PGApp
    def initialize(app_name)
      @app_name = app_name
    end

    def transfers
      http_get "#{@app_name}/transfers"
    end

    def transfers_public_url(id)
      http_post "#{@app_name}/transfers/#{URI.encode(id.to_s)}/actions/public-url"
    end

    private

    def http_get(path)
      retry_on_exception(RestClient::Exception) do
        response = heroku_postgresql_resource[path].get
        JSON.parse(response.to_s).deep_symbolize_keys
      end
    end

    def http_post(path, payload = {})
      response = heroku_postgresql_resource[path].post(JSON.generate(payload))
      JSON.parse(response.to_s).deep_symbolize_keys
    end

    def retry_on_exception(*exceptions)
      retry_count = 0
      begin
        yield
      rescue *exceptions => ex
        raise ex if retry_count >= 3
        sleep 3
        retry_count += 1
        retry
      end
    end

    def heroku_postgresql_resource
      RestClient::Resource.new(
        "https://postgres-api.heroku.com/client/v11/apps",
        password: ENV['HEROKU_API_KEY'],
        headers: { x_heroku_gem_version: "3.43.9" }
      )
    end
  end
end
