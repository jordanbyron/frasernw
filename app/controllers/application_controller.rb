class ApplicationController < ActionController::Base
  include ControllerAuthentication
  before_filter [:redirect_if_old, :login_required]
  protect_from_forgery
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You are not allowed to access this page"
  end

  def redirect_if_old
    if request.host == "frasernw.heroku.com"
      redirect_to "http://pathwaysbc.herokuapp.com#{request.fullpath}", :status => :moved_permanently
    end
  end
end
