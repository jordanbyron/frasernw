class UserSession < Authlogic::Session::Base
  self.consecutive_failed_logins_limit ENV["FAILED_LOGIN_LIMIT"].to_i || 5
  self.failed_login_ban_for 2.hours
  self.logout_on_timeout = true
end
