class UserSessionsController < ApplicationController
  skip_before_filter :login_required
  skip_authorization_check
  
  def index
    redirect_to root_url
  end
  
  def show
    redirect_to root_url
  end

  def new
    @user_session = UserSession.new
    @user = User.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to_target_or_default root_url
    else
      @user = User.new
      render :action => 'new'
    end
  end

  def destroy
    @user_session = current_user_session
    if @user_session.nil?
      redirect_to '/', :notice => "You are not logged in."
    else
      @user_session.destroy 
      redirect_to '/', :notice => "You have been logged out."
    end
  end
end
