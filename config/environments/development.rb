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
  if ENV["CACHE_CLASSES"] == "true"
    config.cache_classes = true

    puts "==> Application code will not be reloaded on every request."
  else
    config.cache_classes = false
  end

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local  = true

  if ENV["CACHE"] == "true"
    config.action_controller.perform_caching = true
    config.cache_store = :dalli_store, { :value_max_bytes => 10485760 }

    puts "==> Rails cache is activated.  Make sure you have memcached on (`memcached -I 5m &`)."
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  if ENV["NAVBAR_SEARCH"] == "true"
    puts "==> Top nav search enabled."
  end

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
    if ENV["BULLET"] == "true"
      Bullet.enable = true

      puts "==> Bullet gem enabled.  (Bullet logs n+1 queries.)"
    else
      false
    end

    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end
