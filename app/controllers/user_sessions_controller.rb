class UserSessionsController < ApplicationController
  skip_before_filter :require_authentication
  skip_authorization_check

  def new
    @user_session = UserSession.new
    @user = User.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      return_to = session[:return_to]
      session[:return_to] = nil
      if @user_session.user.introspective?
        redirect_to home_path
      else
        redirect_to (return_to || root_url)
      end
    else
      @user = User.new
      render action: 'new'
    end
  end

  def destroy
    @user_session = current_user_session
    if @user_session.nil?
      redirect_to login_path, notice: "You are not logged in."
    else
      @user_session.destroy
      redirect_to login_path, notice: "You have been logged out."
    end
  end

end
