class ClinicsController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper
  
  cache_sweeper :clinic_sweeper, :only => [:create, :update, :destroy]

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
    @clinic.build_location
    s = @clinic.build_schedule
    s.build_monday
    s.build_tuesday
    s.build_wednesday
    s.build_thursday
    s.build_friday
    s.build_saturday
    s.build_sunday
    @clinic.location.build_address
    @clinic.focuses.build
    @clinic.attendances.build
    @clinic_procedures = ancestry_options( @specialization.non_assumed_procedure_specializations_arranged )
    @clinic_specialists = @specialization.specialists.collect { |s| [s.name, s.id] }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @clinic = Clinic.new(params[:clinic])
    if @clinic.save
      redirect_to clinic_path(@clinic), :notice => "Successfully created #{@clinic.name}."
    else
      render :action => 'new'
    end
  end

  def edit
    @clinic = Clinic.find(params[:id])
    if @clinic.location.blank?
      @clinic.build_location
      @clinic.location.build_address
    elsif @clinic.location.address.blank?
      @clinic.location.build_address
    end
    if @clinic.focuses.count == 0
      @clinic.focuses.build
    end
    @clinic_procedures = []
    @clinic.specializations_including_in_progress.each { |specialization| 
      @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
      @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
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
      redirect_to @clinic, :notice  => "Successfully updated #{@clinic.name}."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @clinic = Clinic.find(params[:id])
    name = @clinic.name
    @clinic.destroy
    redirect_to clinics_url, :notice => "Successfully deleted #{name}."
  end
  
  def edit_referral_forms
    @entity = Clinic.find(params[:id])
    @entity.referral_forms.build if @entity.referral_forms.length == 0
    @entity_type = "clinic"
    render :template => 'referral_form/edit', :layout => 'ajax' if request.headers['X-PJAX']
  end
end
