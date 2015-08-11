if Rails.env.development?
  # don't spam our logs in dev
  Rack::Timeout.unregister_state_change_observer(:logger)
end
