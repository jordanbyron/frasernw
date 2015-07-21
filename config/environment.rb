# Load the rails application
require File.expand_path('../application', __FILE__)

heroku_env = File.join(Rails.root, 'config', 'heroku_env.rb')
load(heroku_env) if File.exists?(heroku_env)

def self.system_notification_recipients
  (ENV['SYSTEM_NOTIFICATION_RECIPIENTS'] || "").split(";")
end

# Initialize the rails application
Frasernw::Application.initialize!

Time::DATE_FORMATS[:schedule_time] = "%l:%M %p"
Date::DATE_FORMATS[:yyyymmdd] = "%Y%m%d"
Time::DATE_FORMATS[:date_ordinal] = "%B %e, %Y"
