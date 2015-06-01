# # Rails 3.1.12
# Be sure to restart your server when you modify this file.
#
# This file contains the settings for ActionController::ParametersWrapper
# which will be enabled by default in the upcoming version of Ruby on Rails.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActionController::Base.wrap_parameters format: [:json]

# Disable root element in JSON by default.
if defined?(ActiveRecord)
  ActiveRecord::Base.include_root_in_json = false
end

# # Rails 3.2.16:
# # Be sure to restart your server when you modify this file.
# # This file contains settings for ActionController::ParamsWrapper which
# # is enabled by default.
 
# # Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
# ActiveSupport.on_load(:action_controller) do
#   wrap_parameters format: [:json]
# end
 
# # Disable root element in JSON by default.
# ActiveSupport.on_load(:active_record) do
#   self.include_root_in_json = false
# end