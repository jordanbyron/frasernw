class HealthcareProvidersController < ApplicationController
  load_and_authorize_resource
  
  cache_sweeper :healthcare_provider_sweeper, :only => [:create, :update, :destroy]
  
  def index
    @healthcare_providers = HealthcareProvider.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @healthcare_provider = HealthcareProvider.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @healthcare_provider = HealthcareProvider.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @healthcare_provider = HealthcareProvider.new(params[:healthcare_provider])
    if @healthcare_provider.save
      redirect_to @healthcare_provider, :notice => "Successfully created healthcare provider."
      else
      render :action => 'new'
    end
  end
  
  def edit
    @healthcare_provider = HealthcareProvider.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @healthcare_provider = HealthcareProvider.find(params[:id])
    HealthcareProviderSweeper.instance.before_controller_update(@healthcare_provider)
    if @healthcare_provider.update_attributes(params[:healthcare_provider])
      redirect_to @healthcare_provider, :notice  => "Successfully updated healthcare provider."
      else
      render :action => 'edit'
    end
  end
  
  def destroy
    @healthcare_provider = HealthcareProvider.find(params[:id])
    HealthcareProviderSweeper.instance.before_controller_destroy(@healthcare_provider)
    @healthcare_provider.destroy
    redirect_to healthcare_providers_url, :notice => "Successfully deleted healthcare provider."
  end
end
