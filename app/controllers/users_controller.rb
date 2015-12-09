class UsersController < ApplicationController
  load_and_authorize_resource
  skip_before_filter :login_required, :only => [:validate, :signup, :setup]

  def index
    if params[:division_id].present?
      @division = Division.find(params[:division_id])
      if current_user_is_super_admin?
        @super_admin_users = User.includes(:divisions, [:specialization_options => :specialization]).in_divisions([@division]).active_super_admin
      end
      @admin_users = User.includes(:divisions, [:specialization_options => :specialization]).in_divisions([@division]).active_admin_only
      @users = User.includes(:divisions).in_divisions([@division]).active_user
      @pending_users = User.includes(:divisions).in_divisions([@division]).active_pending
      @inactive_users = User.includes(:divisions).in_divisions([@division]).inactive
    else
      if current_user_is_super_admin?
        @super_admin_users = User.includes(:divisions, [:specialization_options => :specialization]).active_super_admin
      end
      @admin_users = User.includes(:divisions, [:specialization_options => :specialization]).active_admin_only
      @users = User.includes(:divisions).active_user
      @pending_users = User.includes(:divisions).active_pending
      @inactive_users = User.includes(:divisions).inactive
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @user = User.new
    build_user_form
    @new_user = true
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @user = User.new(params[:user])
    redirect_to new_user_url, :alert => "Create New User Failed:  At least one division must be chosen." and return if @user.divisions.blank?
    if @user.save :validate => false #so we can avoid setting up with emails or passwords
      redirect_to @user, :notice => "User #{@user.name} successfully created."
    else
      render :action => 'new', :notice => "User Create Failed"
    end
  end

  def edit
    @user = User.find(params[:id])
    build_user_form
    @new_user = false
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @user = User.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    if @user.save :validate => false #so we can edit a pending account
      redirect_to @user, :notice  => "Successfully updated user."
    else
      @new_user = false
      render :action => 'edit'
    end
  end

  def validate
    if params.blank? || params[:user].blank?
      redirect_to login_url
    else
      @user = User.find_by_saved_token(params[:user][:saved_token].downcase)
      if @user.blank?
        redirect_to login_url, :alert  => "Sorry, your access key was not recognized."
      elsif @user.email.present?
        redirect_to login_url, :alert  => "Your access key has already been used to set up an account. Please enter the e-mail address and password associated with your account, and press 'Log in'"
      else
        @email = params[:user][:email]
        render :action => 'signup', :layout => 'user_sessions'
      end
    end
  end

  def setup
    if user_from_saved_token.known?
      if user_from_saved_token.update_attributes(params[:user])
        user_from_saved_token.activated_at = Date.current
        user_from_saved_token.save
        redirect_to login_url, :notice  => "Your account has been set up; please log in using #{@user.email} and your newly created password. Welcome to Pathways!"
      else
        render :action => 'signup', layout: "user_sessions"
      end
    else
      redirect_to login_url, :alert  => "Sorry, your access key was not recognized."
    end
  end

  def change_name
    @user = current_user
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update_name
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to root_url, :layout => 'ajax', :notice => "Your name was successfully changed to #{@user.name}."
    else
      render :action => :change_name, :layout => 'user_sessions'
    end
  end

  def change_local_referral_area
    @user = current_user
    @local_referral_cities = {}
    City.all.each do |city|
      @local_referral_cities[city.id] = []
    end
    Specialization.all.each do |specialization|
      @user.divisions.each do |division|
        cities = @user.local_referral_cities(specialization)
        cities = division.local_referral_cities(specialization) if cities.blank?
        cities.each do |city|
          @local_referral_cities[city.id] << specialization.id
        end
      end
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update_local_referral_area
    @user = current_user
    @user.user_cities.each do |uc|
      #remove existing cities that no longer exist
      UserCity.destroy(uc.id) if (params[:city].blank? || !(params[:city].include? uc.city_id))
    end
    if params[:city].present?
      #add new cities
      params[:city].each do |city_id, set|
        UserCity.find_or_create_by_user_id_and_city_id( @user.id, city_id )
      end
    end
    @user.user_city_specializations.each do |ucs|
      #remove existing specializations that no longer exist
      UserCitySpecialization.destroy(ucs.id) if (!(params[:local_referral_cities].include? ucs.city_id) || !(params[:local_referral_cities][usc.city_id].include? usc.specialization_id))
    end
    if params[:local_referral_cities].present?
      #add new specializations
      params[:local_referral_cities].each do |city_id, specializations|
        user_city = UserCity.find_by_user_id_and_city_id( @user.id, city_id )
        if user_city.present?
          #parent city was checked off
          specializations.each do |specializations_id, set|
            UserCitySpecialization.find_or_create_by_user_city_id_and_specialization_id( user_city.id, specializations_id )
          end
        end
      end
    end
    redirect_to root_url, :layout => 'ajax', :notice => "Your local referral area was successfully updated."
  end

  def change_email
    @user = current_user
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update_email
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to login_url, :layout => 'user_sessions', :notice => "Your e-mail address was successfully changed to #{@user.email}, please log in again with your new e-mail address."
    else
      render :action => :change_email, :layout => 'user_sessions'
    end
  end

  def change_password
    @user = current_user
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to login_url, :layout => 'user_sessions', :notice => "Your password was successfully changed, please log in again with your new password."
    else
      render :action => :change_password, :layout => 'user_sessions'
    end
  end

  def upload
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def import
    divisions = []
    params[:division_ids].each do |division_id|
      next if division_id.blank?
      divisions << Division.find(division_id)
    end
    if divisions.blank?
      redirect_to upload_users_url, :layout => 'ajax', :notice => "At least one division must be chosen."
    else
      @users = User.import(params[:file], divisions, params[:type_mask], 'user')
      render :layout => 'ajax' if request.headers['X-PJAX']
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "Successfully deleted user."
  end

  private

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

  def build_user_form
    @user.user_controls_specialist_offices.build
    @user.user_controls_clinic_locations.build
    @formatted_clinic_locations = ClinicLocation.all_formatted_for_user_form
    @formatted_specialist_offices = SpecialistOffice.cached_all_formatted_for_user_form
  end
end
