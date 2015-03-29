class ApplicationController < ActionController::Base
  include ControllerAuthentication
  before_filter :redirect_to_cedar
  protect_from_forgery
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You are not allowed to access this page"
  end

  def redirect_to_cedar
    redirect_to "http://pathwaysbc.herokuapp.com", :status => :moved_permanently
  end
end
