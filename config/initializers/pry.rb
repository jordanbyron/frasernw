if ENV['APP_NAME'] == "pathwaysbc"
  color = :red
  warning = "[Production] "
elsif !Rails.env.development?
  color = :yellow
  warning = ""
elsif Rails.env.development?
  color = :cyan
  warning = ""
end

Pry.config.prompt_name = Pry::Helpers::Text.send(
  color,
  "#{warning}pry@#{ENV['APP_NAME']}"
)
