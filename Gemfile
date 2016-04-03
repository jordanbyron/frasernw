source 'https://rubygems.org'

ruby '2.2.4'

gem 'nokogiri'
#gem 'rails', '3.1.12'
gem 'rails', '~> 3.2.22'

gem 'pg'

group :production do
  gem 'heroku_cloud_backup',
    git: "https://github.com/pathwaysmedical/heroku_cloud_backup.git",
    ref: "8e801df1ad59515c3a89456169770b641d8c39a2"
end

gem 'redis'

# gem 'goldiloader' #automate eagerloading to squash N+1 queries

# # Asset template engines
# gem 'sass-rails', "~> 3.1.0"
# gem 'coffee-script'
# gem 'uglifier'

#sass here breaks with sprockets:
# group :assets do
#   gem "sass-rails", '~> 4.0.5'
#   gem "sass"
#   gem 'coffee-rails', '~> 3.2.2'
#   gem 'uglifier',     '>= 1.0.3'
# end

#Rails 3.2 upgrade gemfile recommendation
group :assets do
  gem 'sass', '~> 3.1.10'
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'connection_pool'
gem 'highcharts-rails'
gem 'jquery-rails', '~> 1.0.16'
gem 'haml-rails', '~> 0.4'
gem 'brakeman'

gem 'authlogic'
gem 'paper_trail', '~> 2.7'
gem 'will_paginate', '~> 3.0.0'
gem "simple_form", '~> 2.1'
gem "nested_form", :git => "https://github.com/warneboldt/nested_form.git", :ref => "35a2cf060680280413880337a3f89bdec469301c"
#gem 'nested_form', '0.3.2', :path => '~/Documents/Programming/Pathways/warneboldt/nested_form/'
gem 'exception_notification'
gem 'slack-notifier'
gem 'cancan', '1.6.7'
gem "paperclip", "~> 2.7"

gem 'rack-attack'

#Avoid known issue w/ paperclip
#http://stackoverflow.com/questions/28374401/nameerror-uninitialized-constant-paperclipstorages3aws
gem "aws-sdk", "< 2.0"
gem 'public_activity'

# Use unicorn as the web server
gem 'unicorn'

# Enables preloading associations of already loaded records to avoid n + 1's
gem 'edge_rider'

# Heroku caching
gem 'kgio'
gem 'dalli'
gem 'rack-cache'

# Work Queuing
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'

# cron jobs
gem 'clockwork'

# markdown
gem 'bluecloth'
gem 'htmlentities'

#Helper Gems
gem 'wannabe_bool', "~> 0.1.0" #get access to handy to_b boolean method
gem 'valid_url' #parse urls for validity
gem 'indefinite_article' # parse words for "a" or "an"

gem 'hirefire-resource' # auto-scale heroku dynos based on demand

# Make shell pretty
gem 'hirb', :require => false
gem 'awesome_print', :require => false

gem 'bugsnag'

# nice object attribute definition syntax
gem 'virtus'

# Deploy with Capistrano
# gem 'capistrano'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development, :test do
  #gem 'sqlite3'
  gem "nifty-generators"
  gem 'rspec', '~> 3.2'
  gem 'rspec-rails'
  gem 'spork', '> 0.9.0rc'
  # To use debugger
  # gem 'ruby-debug19', :require => 'ruby-debug'
  # can't include rb-fsevent here as heroku doesn't like it
  # gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'guard-spork'
  gem 'rack-livereload'
  gem 'activerecord-import'
  gem 'taps'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'quiet_assets'
  gem 'faker'
end

group :development do
  #gem 'rack-mini-profiler' # latest: gem 'rack-mini-profiler', git: 'git://github.com/MiniProfiler/rack-mini-profiler.git'
  #gem 'lol_dba' # looks for places to add indexes
  gem 'oink'
  gem 'peek'
  gem 'annotate', '~> 2.6.5' #inserts schema as a comment into model code, to run~> annotate
  gem 'letter_opener' # opens mail in browser
  gem 'rails-erd' # makes graph of schema
  gem 'bullet' #warns about N+1 queries
  gem 'thin'
  gem 'iron_fixture_extractor' # extract out data into fixtures
  gem 'table_print' # print nice tables in IRB with tp command
  gem 'quick_spreadsheet', '0.1.0',
    git: "https://github.com/pathwaysmedical/quick_spreadsheet.git",
    ref: 'b204ca5d314b30d7d134a7369be03b649c6c19d8'
end

gem 'pry-rails'
group :development, :test do
  gem 'pry-doc'
  gem 'pry-nav'
  gem 'pry-stack_explorer'
end

gem 'ancestry', '~> 1.3.0' #ancestry breaks specialization.rb arrange methods in higher versions

gem 'validates_email_format_of'
gem "safety_mailer" # prevent emails getting sent in staging

# Google Analytics
gem 'google-api-client', '0.7.1', require: "google/api_client"

gem 'jquery-datatables-rails', '3.1.1'
gem "rack-timeout"

#for Heroku deployment
gem 'rails_12factor', group: :production

# Added to deal with error booting in Ruby 2.2: https://github.com/drapergem/draper/issues/690
gem 'test-unit', '~> 3.0'

#New Relic guide recommends placing New Relic gem at bottom of Gemfile
group :development, :production do
  gem 'newrelic_rpm'
end
