class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include PublicActivity::StoreController
  before_filter :require_authentication
  before_filter :set_heartbeat_loader
  before_filter :load_application_layout_data
  protect_from_forgery
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You are not allowed to access this page"
  end

  def set_heartbeat_loader
    @layout_heartbeat_loader = true
  end

  def load_application_layout_data
    @divisions = Division.all_cached
  end
end
