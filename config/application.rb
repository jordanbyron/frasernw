require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups(:assets => %w(development test))) if defined?(Bundler)

module Frasernw
  class Application < Rails::Application
    config.autoload_paths << "#{config.root}/lib"    # Settings in config/environments/* take precedence over those specified here.
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    # Defaults to '/assets'
    config.assets.prefix = '/asset-files'

    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Please note that JavaScript expansions are *ignored altogether* if the asset
    # pipeline is enabled (see config.assets.enabled below). Put your defaults in
    # app/assets/javascripts/application.js in that case.
    #
    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(prototype prototype_ujs)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.version = '1.0'

    Sprockets::Compressors.register_css_compressor(:scss, 'Sass::Rails::CssCompressor', :require => 'sass/rails/compressor') #added due to heroku error, read: https://github.com/rails/sass-rails/issues/111

    #compress assets before serving, only use below if not on CDN:
    # config.middleware.insert_before ActionDispatch::Static, Rack::Deflater
    #if with CDN (https://robots.thoughtbot.com/content-compression-with-rack-deflater):
    # config.middleware.use Rack::Deflater

    # mailer
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => ENV['SMTP_USER'],
      :password             => ENV['SMTP_PASS'],
      :authentication       => "plain",
      :enable_starttls_auto => true
    }

    config.action_mailer.default_url_options = { :host => "pathwaysbc.ca" }
  end
end
