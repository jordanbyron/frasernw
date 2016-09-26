require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
require 'wannabe_bool'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Frasernw
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.

    # Load ENV vars from local file if it's there
    config.before_configuration do
      heroku_env = File.join(Rails.root, 'config', 'heroku_env.rb')
      load(heroku_env) if File.exists?(heroku_env)
    end

    # So we have global access to a proper array
    config.system_notification_recipients =
      (ENV['SYSTEM_NOTIFICATION_RECIPIENTS'] || "").split(";")

    # Reusable use cases
    config.eager_load_paths << "#{config.root}/app/services"

    # Classes that we could use outside of this app
    config.eager_load_paths << "#{config.root}/lib"

    # Domain objects ("things") that don't have a directly corresponding table
    config.eager_load_paths << "#{config.root}/app/domain"

    # Mixins for domain objects, regardless of whether
    # they inherit from ActiveSupport::Concern or not
    config.eager_load_paths << "#{config.root}/app/concerns"

    config.assets.precompile += ["error_catching.js"]
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.paths << "#{Rails.root}/vendor/assets/javascripts"
    # Defaults to '/assets'
    config.assets.prefix = '/assets'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # True expects attr_accessible to be defined in every model. Maybe one day ...
    config.active_record.whitelist_attributes = false

    # mailer
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => ENV['SMTP_USER'],
      :password             => ENV['SMTP_PASS'],
      :authentication       => "plain",
      :enable_starttls_auto => true
    }
    # To mask the emails of patients who are being mailed content
    # TODO: figure out why specifying on a per- mailer class basis isn't working
    config.action_mailer.logger = nil

    _default_url_options = {
      host: ENV['DOMAIN'],
      protocol: ENV['SCHEME']
    }
    Rails.application.routes.default_url_options = _default_url_options
    config.action_mailer.default_url_options = _default_url_options

    if ENV['RACK_ATTACK'].to_b
      config.middleware.use Rack::Attack
    end

    # Explicitly set the primary key, since AR seems to be unable to find it
    ActiveRecord::SessionStore::Session.primary_key = 'id'

  end
end
