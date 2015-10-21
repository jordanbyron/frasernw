class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include PublicActivity::StoreController
  before_filter :login_required
  before_filter :set_heartbeat_loader
  protect_from_forgery
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You are not allowed to access this page"
  end

  def set_heartbeat_loader
    @layout_heartbeat_loader = true
  end
end
