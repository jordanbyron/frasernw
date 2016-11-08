class PasswordResetsController < ApplicationController
  skip_authorization_check
  skip_before_filter :require_authentication
  before_filter :must_be_logged_out
  before_filter :load_user_using_perishable_token, only: [ :edit, :update ]

  def new
    @user = User.new
    @email = params.present? ? params[:email] : ''
    render layout: 'user_sessions'
  end

  def create
    if params.blank? || params[:user].blank? || params[:user][:email].blank?
      @user = User.new
      redirect_to new_password_reset_url,
        layout: 'user_sessions',
        notice: "We do not have any account that uses that e-mail address as "\
          "a login. Please check the e-mail address you used and try again."
    else
      @user = User.find_by_email(params[:user][:email])
      if @user
        @user.deliver_password_reset_instructions!
        redirect_to login_url,
          layout: 'user_sessions',
          notice: "Instructions to reset your password have been e-mailed to "\
            "#{@user.email}. Please check your e-mail."
      else
        @user = User.new
        redirect_to new_password_reset_url,
          layout: 'user_sessions',
          notice: "We do not have any account associated with "\
            "#{params[:user][:email]}. Please check the e-mail address you "\
            "used and try again. Email addresses are case sensitive. "\
            "Please <a href='#{contact_path}'>contact us</a> if you "\
            "continue encountering problems.".html_safe
      end
    end
  end

  def edit
    render layout: 'user_sessions'
  end

  def update
    if @user.update_attributes(params[:user])
      @user.failed_login_count = 0
      @user.save!
      redirect_to login_url,
        layout: 'user_sessions',
        notice: "Your password was successfully changed."
    else
      render action: :edit,
        layout: 'user_sessions',
        notice: "We had problems updating your password. Please try again. "\
          "If you continue to encounter problems please "\
          "<a href='#{contact_path}'>contact us</a>.".html_safe
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      redirect_to login_url,
        layout: 'user_sessions',
        alert: "Sorry, no account is associated with that password reset "\
          "address. It's possible this link has expired; please try "\
          "resetting your password again."
    end
  end
end
