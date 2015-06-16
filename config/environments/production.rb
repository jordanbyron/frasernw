Frasernw::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # ExceptionNotifier rack middleware
  Frasernw::Application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[mdpathway exception] [#{ENV['APP_NAME']}]",
      :sender_address => %{"Pathways" <system@mdpathwaysbc.com>},
      :exception_recipients => %w{warneboldt@gmail.com khannan@mdpathwaysbc.com bgracie@pathwaysbc.ca}
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
      config.cache_store = :dalli_store, ENV["MEMCACHEDCLOUD_SERVERS"].split(','), { :username => ENV["MEMCACHEDCLOUD_USERNAME"], :password => ENV["MEMCACHEDCLOUD_PASSWORD"] , :value_max_bytes => 10485760}
  elsif ENV["MEMCACHIER_SERVERS"]
      config.cache_store = :dalli_store
  else
      config.cache_store = :dalli_store
  end

  if ENV['APP_NAME'] == "pathwaysbc" #unless Production, override and do not send mail unless to these emails:
  else
    config.action_mailer.delivery_method = :safety_mailer
    config.action_mailer.safety_mailer_settings = {
      allowed_matchers: [ /khannan@mdpathwaysbc.com/, /warneboldt@gmail.com/, /kelseyh@gmail.com/, /bgracie@pathwaysbc.ca/ ],
      delivery_method: :smtp,
      delivery_method_settings: {
        :address => "smtp.gmail.com",
        :port => 587,
        :domain => "http://pathwaysbc.ca",
        :authentication => :plain,
        :user_name => ENV['SMTP_USER'],
        :password => ENV['SMTP_PASS']
      }
    }
  end

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  ##Added for Rails3.0 to 3.1
  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true
  ##

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( ie.css print.css font-awesome-ie7.css patient_information.css jquery-1.7.2.min.js components/*.js views/*.js)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
