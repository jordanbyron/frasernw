class ApplicationController < ActionController::Base
  include ControllerAuthentication
  before_filter :login_required
  protect_from_forgery
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You are not allowed to access this page"
  end
end
