# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
  Rails.application.config.filter_parameters += [
    :password, :password_confirmation, :saved_token, :secret_token,
    :access_key_id, :secret_access_key, :persistence_token, :crypted_password,
    :password_salt, :perishable_token, :patient_email
  ]
