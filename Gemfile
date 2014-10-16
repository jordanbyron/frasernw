source 'https://rubygems.org'

ruby "1.9.3"
#gem 'rails', '3.1.10'
gem 'rails', '3.2.18'

gem 'pg'

group :production do
  gem 'newrelic_rpm'
  gem 'heroku_cloud_backup'
end

# # Asset template engines
# gem 'sass-rails', "~> 3.1.0"
# gem 'coffee-script'
# gem 'uglifier'

#added for rails 3.2 upgrade
group :assets do
  gem "sass-rails"
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'
#gem 'haml-rails'
gem "haml-rails", "~> 0.4.0"
gem 'html2haml'


gem 'authlogic'
gem 'paper_trail', '~> 2'
gem 'will_paginate', '~> 3.0.0'
gem "simple_form", "~> 2.0.1"
gem "nested_form", :git => "https://github.com/warneboldt/nested_form.git", :ref => "35a2cf060680280413880337a3f89bdec469301c"
#gem 'nested_form', '0.3.2', :path => '~/Documents/Programming/Pathways/warneboldt/nested_form/'
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
gem 'htmlentities'

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
  #gem 'heroku'
  gem 'taps'
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git', :require => 'rails_development_boost'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'awesome_print'
  gem 'oink'
end

gem 'ancestry'
gem 'mechanize'
gem 'validates_email_format_of'

# Google Analytics
gem 'gattica', :git => 'git://github.com/chrisle/gattica.git'
gem 'lazy_high_charts'
#gem 'jquery-datatables-rails'
gem 'jquery-datatables-rails', '~> 2.2.1'

