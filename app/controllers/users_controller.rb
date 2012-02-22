class UsersController < ApplicationController
  skip_authorization_check :only => [:create]
  load_and_authorize_resource

  def index
    @users = User.find(:all)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @user = User.new
    @user.user_controls_specialists.build
    @user.user_controls_clinics.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path, :notice => "User #{@user.username} successfully created."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @user.user_controls_specialists.build
    @user.user_controls_clinics.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  # def update
  #   @user = current_user
  #   if @user.update_attributes(params[:user])
  #     redirect_to root_url, :notice => "Your profile has been updated."
  #   else
  #     render :action => 'edit'
  #   end
  # end
  
  def show
    @user = User.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to users_url, :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "Successfully deleted user."
  end
  
end
