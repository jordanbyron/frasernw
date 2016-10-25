# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
#
#   <% if logged_in? %>
#     Welcome <%= current_user.username %>.
#     <%= link_to "Edit profile", edit_current_user_path %> or
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
#
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :require_authentication, except: [:index, :show]
module ControllerAuthentication
  def self.included(controller)
    controller.send :helper_method, :current_user, :logged_in?
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user =
      (current_user_session && current_user_session.record) ||
        UnauthenticatedUser.new
  end

  def logged_in?
    current_user.authenticated?
  end

  def require_authentication
    if !logged_in?
      begin
        $redis.hincrby("require_authentication", request.remote_ip, 1)
      rescue
      end

      session[:return_to] = request.url

      redirect_to login_url,
        alert: log_in_alert
    end
  end

  def must_be_logged_out
    if logged_in?
      redirect_to root_url, alert: "You must be logged out to access this page."
    end
  end

  def token_required(klass, token, id)
    @secret_token_id = SecretToken.where(token: token).first.try(:id)

    unless klass.find(id).valid_tokens.include?(token)
      redirect_to login_url,
        alert: "Invalid token. Please <a href='#{contact_path}'>contact us</a>"\
          " to request or reset your secret url for editing."
    end
  end

  private

  def log_in_alert
    (request.url != root_url) ? "You must log in to access this page." : false
  end
end
