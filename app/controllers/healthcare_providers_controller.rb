class HealthcareProvidersController < ApplicationController
  load_and_authorize_resource
  
  def index
    @healthcare_providers = HealthcareProvider.all
  end
  
  def show
    @healthcare_provider = HealthcareProvider.find(params[:id])
  end
  
  def new
    @healthcare_provider = HealthcareProvider.new
  end
  
  def create
    @healthcare_provider = HealthcareProvider.new(params[:healthcare_provider])
    if @healthcare_provider.save
      redirect_to @healthcare_provider, :notice => "Successfully created healthcare_provider."
      else
      render :action => 'new'
    end
  end
  
  def edit
    @healthcare_provider = HealthcareProvider.find(params[:id])
  end
  
  def update
    @healthcare_provider = HealthcareProvider.find(params[:id])
    if @healthcare_provider.update_attributes(params[:healthcare_provider])
      redirect_to @healthcare_provider, :notice  => "Successfully updated healthcare_provider."
      else
      render :action => 'edit'
    end
  end
  
  def destroy
    @healthcare_provider = HealthcareProvider.find(params[:id])
    @healthcare_provider.destroy
    redirect_to healthcare_providers_url, :notice => "Successfully destroyed healthcare_provider."
  end
end
