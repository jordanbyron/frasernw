class PasswordResetsController < ApplicationController
  skip_authorization_check
  skip_before_filter :login_required
  before_filter :not_login_required
  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
  
  def new  
    @user = User.new
    render :layout => request.headers['X-PJAX'] ? 'ajax' : 'user_sessions'
  end  
  
  def create  
    if params.blank? || params[:user].blank? || params[:user][:email].blank?
      render :action => :new, :layout => 'user_sessions', :alert => "No user was found with that email address."
    else
      @user = User.find_by_email(params[:user][:email])  
      if @user  
        @user.deliver_password_reset_instructions!  
        redirect_to login_url, :layout => 'user_sessions', :notice => "Instructions to reset your password have been emailed to you. Please check your email."
      else  
        render :action => :new, :layout => 'user_sessions', :alert => "No user was found with that email address." 
      end  
    end
  end  
  
  def edit
    render :layout => 'user_sessions'
  end
  
  def update
    if @user.update_attributes(params[:user])
      redirect_to login_url, :layout => 'user_sessions', :notice => "Your password was successfully changed."
    else
      render :action => :edit, :layout => 'user_sessions'
    end
  end
  
  private
  
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      redirect_to login_url, :layout => 'user_sessions', :alert => "Sorry, no account is associated with that password reset address. It's possible this link has expired; please try resetting your password again." 
    end
  end
end
