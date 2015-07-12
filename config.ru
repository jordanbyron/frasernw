# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Frasernw::Application

if Rails.env.production? || Rails.env.development?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == ENV['DELAYED_JOB_WEB_USER'] && password == ENV['DELAYED_JOB_WEB_PASS']
  end
end