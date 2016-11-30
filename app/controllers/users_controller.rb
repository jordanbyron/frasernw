class UsersController < ApplicationController
  load_and_authorize_resource
  skip_before_filter :require_authentication,
    only: [:validate, :signup, :setup]

  def index
    if params[:division_id].present?
      @division = Division.find(params[:division_id])
      if current_user.as_super_admin?
        @super_admin_users = User.
          includes(:divisions, { specialization_options: :specialization }).
          in_divisions([@division]).active_super_admin
      end
      @admin_users = User.
        includes(:divisions, { specialization_options: :specialization }).
        in_divisions([@division]).
        active_admin_only
      @users = User.includes(:divisions).in_divisions([@division]).active_user
      @introspective_users =
        User.includes(:divisions).in_divisions([@division]).active_introspective
      @pending_users =
        User.includes(:divisions).in_divisions([@division]).active_pending
      @inactive_users =
        User.includes(:divisions).in_divisions([@division]).inactive
    else
      if current_user.as_super_admin?
        @super_admin_users = User.
          includes(:divisions, { specialization_options: :specialization }).
          active_super_admin
      end
      @admin_users = User.
        includes(:divisions, { specialization_options: :specialization }).
        active_admin_only
      @users = User.includes(:divisions).active_user
      @introspective_users = User.includes(:divisions).active_introspective
      @pending_users = User.includes(:divisions).active_pending
      @inactive_users = User.includes(:divisions).inactive
    end
  end

  def new
    @user = User.new
    build_user_form!
    @new_user = true
  end

  def create
    @user = User.new(
      params[:user].merge({ persist_in_demo: (ENV['DEMO_SITE'] == "true") })
    )
    if requirement_missing
      redirect_to new_user_url, notice: requirement_missing and return
    end
    # so we can avoid setting up with emails or passwords
    if @user.save validate: false
      redirect_to @user, notice: "User #{@user.name} successfully created."
    else
      render action: 'new', notice: "User Create Failed"
    end
  end

  def edit
    @user = User.find(params[:id])
    build_user_form!
    @new_user = false
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    if requirement_missing
      redirect_to new_user_url, notice: requirement_missing and return
    end
    if @user.save validate: false # so we can edit a pending account
      redirect_to @user, notice: "Successfully updated user."
    else
      @new_user = false
      render action: 'edit'
    end
  end

  def validate
    if params.blank? || params[:user].blank?
      redirect_to login_url, alert: "Please complete all fields."
    else
      @user = User.find_by_saved_token(params[:user][:saved_token].downcase)
      if @user.blank?
        redirect_to login_url,
          alert: "Sorry, your access key was not recognized."
      elsif @user.email.present?
        redirect_to login_url,
          alert: "Your access key has already been used to set up an account."\
            " Please enter the e-mail address and password associated with "\
            "your account, and press 'Log in'"
      elsif @user.active == false
        redirect_to login_url,
          alert: "Sorry, your access key is no longer active. "\
            "Please <a href='#{contact_path}'>contact us</a>"\
            " to have your account access key reactivated.".
            html_safe
      else
        @email = params[:user][:email]
        render action: 'signup', layout: 'user_sessions'
      end
    end
  end

  def setup
    if user_from_saved_token.known?
      @user_object = user_from_saved_token
      @user_object.assign_attributes(params[:user])
      @user_object.validate_signup
      if (
        !@user_object.errors.present? &&
        user_from_saved_token.update_attributes(params[:user])
      )
        user_from_saved_token.activated_at = Date.current
        user_from_saved_token.save
        redirect_to login_url,
          notice: "Your account has been set up; please log in using "\
            "#{@user.email} and your newly created password. "\
            "Welcome to Pathways!"
      else
        render action: 'signup',
          layout: "user_sessions",
          alert: "Please check all fields and try again."
      end
    else
      redirect_to login_url,
        alert: "Sorry, your access key was not recognized."
    end
  end

  def change_name
    @user = current_user
  end

  def update_name
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to root_url,
      notice: "Your name was successfully changed to #{@user.name}."
    else
      render action: :change_name,
        layout: 'user_sessions',
        alert: "Please check all fields and try again."
    end
  end

  def change_email
    @user = current_user
  end

  def update_email
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to login_url,
        layout: 'user_sessions',
        notice: "Your e-mail address was successfully changed to "\
          "#{@user.email}, please log in again with your new e-mail address."
    else
      render action: :change_email,
        layout: 'user_sessions',
        alert: "Please check all fields and try again."
    end
  end

  def change_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to login_url,
        layout: 'user_sessions',
        notice: "Your password was successfully changed, "\
          "please log in again with your new password."
    else
      render action: :change_password,
        layout: 'user_sessions',
        alert: "Please check all fields and try again."
    end
  end

  def upload
  end

  def import
    divisions = []
    params[:division_ids].each do |division_id|
      next if division_id.blank?
      divisions << Division.find(division_id)
    end
    if divisions.blank?
      redirect_to upload_users_url,
        notice: "At least one division must be chosen."
    else
      @users =
        User.csv_import(params[:file], divisions, params[:type_mask], 'user')
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_url, notice: "Successfully deleted user."
    else
      render action: :show, alert: "Failed to delete user."
    end
  end

  private

  def requirement_missing
    if (@user.name.blank? && @user.divisions.blank?)
      "User create failed: User is missing a Name and a Division"
    elsif @user.name.blank?
      "User create failed: User is missing a Name"
    elsif @user.divisions.blank?
      "User create failed: User is missing a Division"
    else
      nil
    end
  end

  def user_for_paper_trail
    if self.action_name == "setup"
      if user_from_saved_token.known?
        user_from_saved_token.id.to_s
      else
        nil
      end
    else
      current_user.try(:id).to_s
    end
  end

  def user_from_saved_token
    @user ||= begin
      if params.blank? || params[:user].blank?
        UnknownUser.new
      else
        User.find_by_saved_token(params[:user][:saved_token].downcase)
      end
    end
  end

  def build_user_form!
    @user.user_controls_specialists.build
    @user.user_controls_clinics.build
    @formatted_clinics = Clinic.
      select{|clinic| clinic.name.present? }.
      sort_by(&:name)

    @formatted_specialists = Specialist.
      select{ |specialist| specialist.name.present? }.
      sort_by do |specialist|
        [ specialist.lastname.capitalize, specialist.firstname ]
      end
  end
end
