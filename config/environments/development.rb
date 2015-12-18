require 'wannabe_bool'
Frasernw::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  ##added for rails 3.2 upgrade:
  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5
  ##

  # turn off asset pipline
  config.assets.debug = true

  # Do not compress assets
  config.assets.compress = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = (ENV["BENCHMARKING"].to_b || false)

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = (ENV["PERFORM_CACHING"].to_b || false)
  config.cache_store = :dalli_store, { :value_max_bytes => 10485760 }

  # # # # # Development Feature Switches:
  # Use to gain more production-like configs in local development; turns cache_classes & perform_caching to true, or includes livesearch.js
  # To use switches, call them when booting a local rails server, e.g.:
  # $~> BENCHMARKING=true PERFORM_CACHING=true LIVESEARCH=true BULLET=true rails s
  if ENV["BENCHMARKING"].to_b == true
    puts "==> BENCHMARKING TURNED ON -- REPEAT REQUESTS CACHE CODE TO IMITATE PRODUCTION"
  end

  if ENV["PERFORM_CACHING"].to_b == true
    puts "==> PERFORM CACHING TURNED ON -- MEMCACHE IS ON TO IMITATE PRODUCTION"
  end

  if ENV["LIVESEARCH"].to_b == true
    puts "==> LIVESEARCH.js file will be included"
  end

  if ENV["BULLET"].to_b == true
    puts "==> BULLET GEM ENABLED --- DETECTED N+1 QUERIES NOW TRIGGER WARNINGS"
  end
  # # # # #

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  #imagemagick path
  Paperclip.options[:command_path] = "/usr/local/bin/"

  #kelseydevnote: added to find bad queries
  Rails.application.middleware.use Oink::Middleware

  config.after_initialize do
    #bullet actions only run if explicitly enabled
    Bullet.enable = (ENV["BULLET"].to_b || false)
    #Bullet.alert = false
    Bullet.bullet_logger = true
    Bullet.console = true
    ##Bullet.growl = true
    Bullet.rails_logger = true
    ## Bullet.bugsnag = true
    ## #Bullet.airbrake = true
    Bullet.add_footer = true
    ##Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
  end

  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => ENV['SMTP_USER'],
    :password             => ENV['SMTP_PASS'],
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

end
