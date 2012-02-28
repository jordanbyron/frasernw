class ClinicsController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper

  def index
    @clinics = Clinic.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @clinic = Clinic.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    #specialization passed in to facilitate javascript "checking off" of starting speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])
    @clinic = Clinic.new
    @clinic.clinic_specializations.build( :specialization_id => @specialization.id )
    @clinic.addresses.build
    @clinic.focuses.build
    @clinic.attendances.build
    @clinic_procedures = ancestry_options( @specialization.procedure_specializations_arranged )
    @clinic_specialists = @specialization.specialists.collect { |s| [s.name, s.id] }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @clinic = Clinic.new(params[:clinic])
    if @clinic.save
      redirect_to clinic_path(@clinic), :notice => "Successfully created clinic."
    else
      render :action => 'new'
    end
  end

  def edit
    @clinic = Clinic.find(params[:id])
    if @clinic.focuses.count == 0
      @clinic.focuses.build
    end
    @clinic_procedures = []
    @clinic.specializations_including_in_progress.each { |specialization| 
      @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
      @clinic_procedures += ancestry_options( specialization.procedure_specializations_arranged )
    }
    @clinic_specialists = []
    @clinic.specializations_including_in_progress.each { |specialization|
      @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
      @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    params[:clinic][:procedure_ids] ||= []
    @clinic = Clinic.find(params[:id])
    if @clinic.update_attributes(params[:clinic])
      redirect_to @clinic, :notice  => "Successfully updated clinic."
    else\
      render :action => 'edit'
    end
  end

  def destroy
    @clinic = Clinic.find(params[:id])
    @clinic.destroy
    redirect_to clinics_url, :notice => "Successfully deleted clinic."
  end
end
