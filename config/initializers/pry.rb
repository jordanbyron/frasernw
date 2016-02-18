# Show red environment name in pry prompt for non development environments, otherwise show blue
# Append PRODUCTION in front for main server

def production?
  ENV['APP_NAME'] == "pathwaysbc" && !Rails.env.development?
end

if production?
  warning = Pry::Helpers::Text.red("PRODUCTION")
  env = Pry::Helpers::Text.red(ENV['APP_NAME'])
  Pry.config.prompt_name = "#{warning} pry@#{env}"  # => [1] PRODUCTION pry@pathwaysbc(main)>

elsif !Rails.env.development?                       # staging server console:
  env = Pry::Helpers::Text.red(ENV['APP_NAME'])
  Pry.config.prompt_name = "pry@#{env}"             # => [1] pry@pathwaysbctest(main)>

else                                                # local development console:
  env = Pry::Helpers::Text.blue(ENV['APP_NAME'])
  Pry.config.prompt_name = "pry@#{env}"             # => [1] pry@pathwaysbcdevelopment(main)>
end