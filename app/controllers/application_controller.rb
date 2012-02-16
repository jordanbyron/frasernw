class ApplicationController < ActionController::Base
  include ControllerAuthentication
  before_filter :login_required
  protect_from_forgery
  check_authorization

  def info_for_paper_trail
    { to_review: (!current_user_is_admin? rescue true) }
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You are not allowed to access this page"
  end
end
