source 'https://rubygems.org'

ruby '2.2.4'

gem 'rails', '~> 4.0.0'

gem 'pg'

group :production do
  gem 'heroku_cloud_backup',
    git: "https://github.com/pathwaysmedical/heroku_cloud_backup.git"
end

gem 'redis'

gem 'sass-rails',   '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

gem 'oj'

# Rails 3.2 to 4 upgrade gems
gem 'protected_attributes'

gem 'activerecord-session_store'

gem 'haml-rails', '~> 0.4'

gem 'authlogic'
gem 'paper_trail'
gem 'will_paginate'
gem "simple_form"

# link_to_add, link_to_remove
gem "nested_form",
  git: "https://github.com/pathwaysmedical/nested_form.git",
  ref: "1b0689dfb4d230ceabd278eba159fcb02f23c68a"

gem 'exception_notification',
  git: 'https://github.com/pathwaysmedical/exception_notification.git',
  ref: '895398d1e71759359e5f2e16d5bec1ac798da90c'

gem 'cancancan'
gem "paperclip"

gem 'rack-attack'

#Avoid known issue w/ paperclip
#http://stackoverflow.com/questions/28374401/nameerror-uninitialized-constant-paperclipstorages3aws
gem "aws-sdk", "< 2.0"

# Use unicorn as the web server
gem 'unicorn'

# Enables preloading associations of already loaded records to avoid n + 1's
gem 'edge_rider'

gem 'dalli'

# Faster io for memcached
gem 'kgio'

# Work Queuing
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'

# cron jobs
gem 'clockwork'

# markdown
gem 'bluecloth'

#Helper Gems
gem 'wannabe_bool'
gem 'valid_url'
gem 'indefinite_article'

# Make shell pretty
gem 'hirb', require: false
gem 'awesome_print', require: false

# nice object attribute definition syntax
gem 'virtus'

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development, :test do
  gem 'rspec', '~> 3.2'
  gem 'rspec-rails'
  gem 'activerecord-import'
  gem 'quiet_assets'
  gem 'faker'
end

group :development do
  gem 'oink'
  gem 'annotate', '~> 2.7' #inserts schema as a comment into model code, to run~> annotate
  gem 'letter_opener' # opens mail in browser
  gem 'rails-erd' # makes graph of schema
  gem 'bullet' #warns about N+1 queries
  gem 'thin'
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

gem 'ancestry'

gem 'validates_email_format_of'
gem "safety_mailer" # prevent emails getting sent in staging

# Google Analytics
gem 'google-api-client', '0.8.6', require: "google/api_client"

gem "rack-timeout"

#for Heroku deployment
gem 'rails_12factor', group: :production

# Added to deal with error booting in Ruby 2.2: https://github.com/drapergem/draper/issues/690
gem 'test-unit', '~> 3.0'

#New Relic guide recommends placing New Relic gem at bottom of Gemfile
group :development, :production do
  gem 'newrelic_rpm'
end
