source 'https://rubygems.org'

ruby "1.9.3"
gem 'rails', '3.1.12'
gem 'pg'

group :production do
  gem 'heroku_cloud_backup'
end

# Asset template engines
gem 'sass-rails', "~> 3.1.0"
gem 'coffee-script'
gem 'uglifier'

gem 'jquery-rails'
gem 'haml-rails'

gem 'authlogic'
gem 'paper_trail', '~> 2.7'
gem 'will_paginate', '~> 3.0.0'
gem "simple_form", "~> 2.0.1"
gem "nested_form", :git => "https://github.com/warneboldt/nested_form.git", :ref => "35a2cf060680280413880337a3f89bdec469301c"
#gem 'nested_form', '0.3.2', :path => '~/Documents/Programming/Pathways/warneboldt/nested_form/'
gem 'exception_notification'
gem "cancan", "~> 1.6.7"
gem "paperclip", "~> 2.7"
gem "aws-sdk"
gem 'public_activity'

# Use unicorn as the web server
gem 'unicorn'

# Heroku caching
gem 'kgio'
gem 'dalli'
gem 'memcachier'
gem 'delayed_job_active_record'
gem 'daemons'

# markdown
gem 'bluecloth'
gem 'htmlentities'

gem 'wannabe_bool', "~> 0.1.0" #get access to handy to_b boolean method


# Deploy with Capistrano
# gem 'capistrano'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

group :development, :test do
  #gem 'sqlite3'
  gem "nifty-generators"
  gem 'rspec'
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
  #gem 'heroku'
  gem 'taps'
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git', :require => 'rails_development_boost'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'awesome_print'
end

group :development do
  gem 'pry-rails' # loads pry by default with rails c
  gem 'oink'
  gem 'rack-mini-profiler'
  #latest: gem 'rack-mini-profiler', git: 'git://github.com/MiniProfiler/rack-mini-profiler.git'
  gem 'lol_dba'
  gem 'letter_opener'
  gem 'debugger'
end

gem 'ancestry'
gem 'mechanize'
gem 'validates_email_format_of'

# Google Analytics
gem 'gattica', :git => 'git://github.com/chrisle/gattica.git'
gem 'lazy_high_charts'
gem 'jquery-datatables-rails'
gem "rack-timeout"


#New Relic guide recommends placing New Relic gem at bottom of Gemfile
group :development, :production do
  gem 'newrelic_rpm'
end

