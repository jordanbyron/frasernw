if ENV['APP_NAME'] == "pathwaysbc"
  color = :red
  warning = "[Production] "
elsif ENV['APP_NAME'] == "pathwaysbctest" || ENV['APP_NAME'] == "pathwaysbcdev"
  color = :yellow
  warning = ""
elsif ENV['APP_NAME'] == "pathwaysbclocal"
  color = :green
  warning = ""
end

colored_env = Pry::Helpers::Text.send(color, ENV['APP_NAME'])
colored_warning = Pry::Helpers::Text.send(color, warning)

Pry.config.prompt_name = "#{colored_warning}pry@#{colored_env}"
