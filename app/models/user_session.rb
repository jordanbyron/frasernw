class UserSession < Authlogic::Session::Base
  self.consecutive_failed_logins_limit logins_limit
  self.failed_login_ban_for 2.hours
  self.logout_on_timeout = true

  def logins_limit
    ENV["FAILED_LOGIN_LIMIT"].nil? ? 5 : ENV["FAILED_LOGIN_LIMIT"].to_i
  end
end
