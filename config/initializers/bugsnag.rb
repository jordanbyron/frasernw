if ENV['BUGSNAG_ENABLED'].to_b
  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_API_KEY']
  end
end