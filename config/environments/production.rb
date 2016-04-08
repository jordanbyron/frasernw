Frasernw::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # ExceptionNotifier rack middleware
  Frasernw::Application.config.middleware.use ExceptionNotification::Rack,
    {
      email: {
        email_prefix: "#{ENV['APP_NAME']} [Exception] ",
        sender_address: %{"Pathways" <system@mdpathwaysbc.com>},
        exception_recipients: config.system_notification_recipients,
        delivery_method: :smtp
      }
    }

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress both stylesheets and JavaScripts
  config.assets.js_compressor  = :uglifier
  config.assets.css_compressor = :scss

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV["FORCE_SSL"].to_b

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  if ENV["MEMCACHEDCLOUD_SERVERS"]
      config.cache_store = :dalli_store,
      ENV["MEMCACHEDCLOUD_SERVERS"].split(','), {
        :username => ENV["MEMCACHEDCLOUD_USERNAME"],
        :password => ENV["MEMCACHEDCLOUD_PASSWORD"] ,
        :value_max_bytes => 10485760
      }
  elsif ENV["MEMCACHIER_SERVERS"]
      config.cache_store = :dalli_store
  else
      config.cache_store = :dalli_store, { :value_max_bytes => 10485760 }
  end

  if !(ENV['APP_NAME'] == "pathwaysbc")
    config.action_mailer.delivery_method = :pathways_dev_mailer
  end

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  config.eager_load = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( ie.css print.css font-awesome-ie7.css patient_information.css jquery-1.7.2.min.js views/*.js)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
