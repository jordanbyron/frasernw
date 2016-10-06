require 'wannabe_bool'
Frasernw::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  if ENV["CACHE_CLASSES"] == "true"
    config.cache_classes = true

    puts "==> Application code will not be reloaded on every request."
  else
    config.cache_classes = false
  end

  config.eager_load = false

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

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = false

  config.active_record.mass_assignment_sanitizer = :strict

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
