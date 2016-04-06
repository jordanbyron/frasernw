if Rails.env.development?
  # don't spam our logs in dev
  Rack::Timeout::Logger.disable
end
