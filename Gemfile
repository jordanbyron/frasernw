source 'https://rubygems.org'

ruby "2.1.2"

gem 'nokogiri'
#gem 'rails', '3.1.12'
gem 'rails', '3.2.21'

gem 'pg'

group :production do
  gem 'heroku_cloud_backup'
end

gem 'goldiloader' #automate eagerloading to squash N+1 queries


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

gem 'jquery-rails', "~> 1.0.16"
#gem 'haml-rails'
gem "haml-rails", "~> 0.4.0"
gem 'html2haml'

gem 'authlogic'
gem 'paper_trail', '~> 2.7'
gem 'will_paginate', '~> 3.0.0'
gem "simple_form", '~> 2.1'
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
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'
gem 'clockwork'

# markdown
gem 'bluecloth'
gem 'htmlentities'

gem 'wannabe_bool', "~> 0.1.0" #get access to handy to_b boolean method
gem 'valid_url' #parse urls for validity
gem 'indefinite_article' # parse words for "a" or "an"



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
end

group :development do
  gem 'pry-rails' # loads pry by default with rails c
  gem 'rack-mini-profiler'
  #latest: gem 'rack-mini-profiler', git: 'git://github.com/MiniProfiler/rack-mini-profiler.git'
  gem 'lol_dba'
  gem 'awesome_print'
  gem 'oink'
  gem 'peek'
  gem 'annotate', '~> 2.6.5' #inserts schema as a comment into model code, to run~> annotate
  gem 'letter_opener' # opens mail in browser
  gem 'rails-erd' # makes graph of schema
  gem 'bullet' #warns about N+1 queries
  gem 'thin'
end

gem 'ancestry', '~> 1.3.0' #ancestry breaks specialization.rb arrange methods in higher versions
gem 'mechanize'
gem 'validates_email_format_of'

# Google Analytics
gem 'gattica', :git => 'git://github.com/chrisle/gattica.git'
gem 'lazy_high_charts'

gem 'jquery-datatables-rails'
gem "rack-timeout"

#for Heroku deployment
gem 'rails_12factor', group: :production

#New Relic guide recommends placing New Relic gem at bottom of Gemfile
group :development, :production do
  gem 'newrelic_rpm'
end
