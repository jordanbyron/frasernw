class SpecializationsController < ApplicationController
  skip_before_filter :login_required, :only => :refresh_cache
  load_and_authorize_resource :except => :refresh_cache
  before_filter :check_token, :only => :refresh_cache
  skip_authorization_check :only => :refresh_cache
  
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
      redirect_to @specialization, :notice => "Successfully created specialization."
    else
      render :action => 'new'
    end
  end

  def edit
    @specialization = Specialization.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @specialization = Specialization.find(params[:id])
    SpecializationSweeper.instance.before_controller_update(@specialization)
    if @specialization.update_attributes(params[:specialization])
      redirect_to @specialization, :notice  => "Successfully updated specialization."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @specialization = Specialization.find(params[:id])
    SpecializationSweeper.instance.before_controller_destroy(@specialization)
    @specialization.destroy
    redirect_to specializations_url, :notice => "Successfully deleted specialization."
  end
  
  def check_token
    token_required( Specialization, params[:token], params[:id] )
  end
  
  def refresh_cache
    @specialization = Specialization.find(params[:id])
    @feedback = FeedbackItem.new
    render :show, :layout => 'ajax'
  end
end
