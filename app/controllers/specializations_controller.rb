class SpecializationsController < ApplicationController
  skip_before_filter :login_required, :only => [:refresh_cache, :refresh_city_cache, :refresh_division_cache]
  load_and_authorize_resource :except => [:refresh_cache, :refresh_city_cache, :refresh_division_cache]
  before_filter :check_token, :only => [:refresh_cache, :refresh_city_cache, :refresh_division_cache]
  skip_authorization_check :only => [:refresh_cache, :refresh_city_cache, :refresh_division_cache]
  
  cache_sweeper :specialization_sweeper, :only => [:create, :update, :destroy]

  def index
    @specializations = Specialization.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @specialization = Specialization.find(params[:id])
    @feedback = FeedbackItem.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @specialization = Specialization.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @specialization = Specialization.new(params[:specialization])
    if @specialization.save
      redirect_to @specialization, :notice => "Successfully created specialty."
    else
      render :action => 'new'
    end
  end

  def edit
    @specialization = Specialization.find(params[:id])
    Division.all.each { |division| SpecializationOwner.find_or_create_by_specialization_id_and_division_id(params[:id], division.id) }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @specialization = Specialization.find(params[:id])
    SpecializationSweeper.instance.before_controller_update(@specialization)
    if @specialization.update_attributes(params[:specialization])
      redirect_to @specialization, :notice  => "Successfully updated specialty."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @specialization = Specialization.find(params[:id])
    SpecializationSweeper.instance.before_controller_destroy(@specialization)
    @specialization.destroy
    redirect_to specializations_url, :notice => "Successfully deleted specialty."
  end
  
  def check_token
    token_required( Specialization, params[:token], params[:id] )
  end
  
  def refresh_cache
    @specialization = Specialization.find(params[:id])
    @feedback = FeedbackItem.new
    render :show, :layout => 'ajax'
  end
  
  def refresh_city_cache
    @specialization = Specialization.find(params[:id])
    @city = City.find(params[:city_id])
    render 'refresh_city.js'
  end
  
  def refresh_division_cache
    @specialization = Specialization.find(params[:id])
    @division = Division.find(params[:division_id])
    render 'refresh_division.js'
  end
end
