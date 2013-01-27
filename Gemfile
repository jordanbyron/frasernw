source 'https://rubygems.org'

gem 'rails', '3.1.10'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'
# gem 'rails',      :git => "git://github.com/rails/rails.git", :branch => "3-1-stable"


group :production do
  gem 'pg'
  gem 'therubyracer-heroku', '0.8.1.pre3'
  gem 'newrelic_rpm'
end

# Asset template engines
gem 'sass-rails', "~> 3.1.0"
gem 'coffee-script'
gem 'uglifier'

gem 'jquery-rails'
gem 'haml-rails'

gem 'authlogic'
gem 'paper_trail', '~> 2'
gem 'will_paginate', '~> 3.0.0'
gem "simple_form", "~> 2.0.1"
gem "nested_form", :git => "https://github.com/warneboldt/nested_form.git", :ref => "230e366a35a2fabd1f2b51d0102237ba684174f0"
gem 'exception_notification'
gem "cancan", "~> 1.6.7"
gem "paperclip", "~> 2.7"
gem "aws-sdk"

# Use unicorn as the web server
gem 'unicorn'

# Heroku caching
gem 'memcachier'
gem 'dalli'
gem 'delayed_job_active_record'
gem 'daemons'

# markdown
gem 'bluecloth'

# Deploy with Capistrano
# gem 'capistrano'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

group :development, :test do
  gem 'sqlite3'
  gem "nifty-generators"
  gem 'rspec'
  gem 'rspec-rails'
  gem 'spork', '> 0.9.0rc'
  # To use debugger
  gem 'ruby-debug19', :require => 'ruby-debug'
  # can't include rb-fsevent here as heroku doesn't like it
  # gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'guard-spork'
  gem 'heroku'
  gem 'taps'
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git', :require => 'rails_development_boost'
  gem 'rb-fsevent', '~> 0.9.1'
end

# gem "mocha", :group => :test

# Automated Heroku DB backups (to Google Storage)
gem 'heroku_cloud_backup'

gem 'ancestry'

# Google Analytics
gem 'gattica', :git => 'git://github.com/chrisle/gattica.git'
gem 'lazy_high_charts'
