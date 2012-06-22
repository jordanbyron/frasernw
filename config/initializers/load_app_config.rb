raw_config = File.read("#{Rails.root}/config/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

if Rails.env.production?
  APP_CONFIG[:domain] = ENV['DOMAIN']
end
