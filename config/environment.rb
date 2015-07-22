# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Frasernw::Application.initialize!

Time::DATE_FORMATS[:schedule_time] = "%l:%M %p"
Date::DATE_FORMATS[:yyyymmdd] = "%Y%m%d"
Time::DATE_FORMATS[:date_ordinal] = "%B %e, %Y"
