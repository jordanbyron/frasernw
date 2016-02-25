# Colour rails console pry shell prompt differently based on environment
if ENV['APP_NAME'] == "pathwaysbc"
  color = :red
  warning = "Production "
elsif !Rails.env.development?
  color = :yellow
  warning = ""
elsif Rails.env.development?
  color = :cyan
  warning = ""
end

colored_env = Pry::Helpers::Text.send(color, ENV['APP_NAME'])
colored_warning = Pry::Helpers::Text.send(color, warning)

Pry.config.prompt_name = "#{colored_warning}pry@#{colored_env}"
