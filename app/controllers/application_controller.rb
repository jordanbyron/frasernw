class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include PublicActivity::StoreController
  before_filter :require_authentication
  before_filter :set_heartbeat_loader
  before_filter :load_application_layout_data
  protect_from_forgery with: :exception
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: "You are not allowed to access this page"
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    redirect_to new_user_session_path,
      alert: "To protect your account's security, Pathways requires you to "\
        "re-attempt login."
  end

  def set_heartbeat_loader
    @layout_heartbeat_loader = true
  end

  def load_application_layout_data
    @divisions = Division.all_cached
  end

  def origin_path(request_origin)
    if request_origin.present?
      if request_origin.start_with?("http://", "https://")
        request_origin
      else
        Base64.decode64(request_origin.to_s)
      end
    else
      root_path
    end
  end
end
