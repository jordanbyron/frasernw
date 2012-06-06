class ClinicsController < ApplicationController
  skip_before_filter :login_required, :only => :refresh_cache
  load_and_authorize_resource :except => :refresh_cache
  before_filter :check_token, :only => :refresh_cache
  skip_authorization_check :only => :refresh_cache
  include ApplicationHelper
  
  cache_sweeper :clinic_sweeper, :only => [:create, :update, :destroy]

  def index
    @clinics = Clinic.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @clinic = Clinic.find(params[:id])
    @feedback = @clinic.feedback_items.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @is_review = false
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
    @clinic.attendances.build
    @clinic_procedures = ancestry_options( @specialization.non_assumed_procedure_specializations_arranged )
    @clinic_specialists = @specialization.specialists.collect { |s| [s.name, s.id] }
    @focuses = []
    @specialization.non_assumed_procedure_specializations_arranged.each { |ps, children|
      @focuses << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
      children.each { |child_ps, grandchildren|
        @focuses << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @clinic = Clinic.new(params[:clinic])
    if @clinic.save
      if params[:focuses_mapped].present?
        params[:focuses_mapped].each do |updated_focus, value|
          focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, updated_focus)
          focus.investigation = params[:focuses_investigations][updated_focus]
          focus.save
        end
      end
      redirect_to clinic_path(@clinic), :notice => "Successfully created #{@clinic.name}."
    else
      render :action => 'new'
    end
  end

  def edit
    @is_review = false
    @clinic = Clinic.find(params[:id])
    if @clinic.location.blank?
      @clinic.build_location
      @clinic.location.build_address
    elsif @clinic.location.address.blank?
      @clinic.location.build_address
    end
    @clinic_procedures = []
    @clinic.specializations_including_in_progress.each { |specialization| 
      @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
      @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
    }
    @clinic_specialists = []
    procedure_specializations = {}
    @clinic.specializations_including_in_progress.each { |specialization|
      @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
      @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
      procedure_specializations.merge!(specialization.non_assumed_procedure_specializations_arranged)
    }
    @focuses = []
    procedure_specializations.each { |ps, children|
      focus = Focus.find_by_clinic_id_and_procedure_specialization_id(@clinic.id, ps.id)
      if focus.present?
        @focuses << { :mapped => true, :name => ps.procedure.name, :id => ps.id, :investigations => focus.investigation, :offset => 0 }
      else
        @focuses << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
      end
      children.each { |child_ps, grandchildren|
        focus = Focus.find_by_clinic_id_and_procedure_specialization_id(@clinic.id, child_ps.id)
        if focus.present?
          @focuses << { :mapped => true, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => focus.investigation, :offset => 1 }
        else
          @focuses << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
        end
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    params[:clinic][:procedure_ids] ||= []
    @clinic = Clinic.find(params[:id])
    ClinicSweeper.instance.before_controller_update(@clinic)
    if @clinic.update_attributes(params[:clinic])
      @clinic.focuses.each do |original_focus|
        Focus.destroy(original_focus.id) if params[:focuses_mapped][original_focus].blank?
      end
      if params[:focuses_mapped].present?
        params[:focuses_mapped].each do |updated_focus, value|
          focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, updated_focus)
          focus.investigation = params[:focuses_investigations][updated_focus]
          focus.save
        end
      end
      redirect_to @clinic, :notice  => "Successfully updated #{@clinic.name}."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @clinic = Clinic.find(params[:id])
    ClinicSweeper.instance.before_controller_destroy(@clinic)
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
  
  def review
    @is_review = true
    @review_item = ReviewItem.find_by_item_type_and_item_id( "Clinic", params[:id] );
    
    if @review_item.blank?
      redirect_to clinics_path, :notice => "There are no review items for this specialist"
    else
      @clinic = Clinic.find(params[:id])
      if @clinic.location.blank?
        @clinic.build_location
        @clinic.location.build_address
        elsif @clinic.location.address.blank?
        @clinic.location.build_address
      end
      @clinic_procedures = []
      @clinic.specializations_including_in_progress.each { |specialization| 
        @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
        @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
      }
      @clinic_specialists = []
      procedure_specializations = {}
      @clinic.specializations_including_in_progress.each { |specialization|
        @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
        @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
        procedure_specializations.merge!(specialization.non_assumed_procedure_specializations_arranged)
      }
      @focuses = []
      procedure_specializations.each { |ps, children|
        focus = Focus.find_by_clinic_id_and_procedure_specialization_id(@clinic.id, ps.id)
        if focus.present?
          @focuses << { :mapped => true, :name => ps.procedure.name, :id => ps.id, :investigations => focus.investigation, :offset => 0 }
          else
          @focuses << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
        end
        children.each { |child_ps, grandchildren|
          focus = Focus.find_by_clinic_id_and_procedure_specialization_id(@clinic.id, child_ps.id)
          if focus.present?
            @focuses << { :mapped => true, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => focus.investigation, :offset => 1 }
            else
            @focuses << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
          end
        }
      }
      render :template => 'clinics/edit', :layout => 'ajax' if request.headers['X-PJAX']
    end
  end
  
  def accept
    #accept changes, destroy the review item so that we can save the clinic
    @clinic = Clinic.find(params[:id])
    
    review_item = @clinic.review_item
    ReviewItem.destroy(review_item)
    
    ClinicSweeper.instance.before_controller_update(@clinic)
    if @clinic.update_attributes(params[:clinic])
      @clinic.focuses.each do |original_focus|
        Focus.destroy(original_focus.id) if params[:focuses_mapped][original_focus].blank?
      end
      params[:focuses_mapped].each do |updated_focus, value|
        focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, updated_focus)
        focus.investigation = params[:focuses_investigations][updated_focus]
        focus.save
      end
      redirect_to @clinic, :notice  => "Successfully updated #{@clinic.name}."
    else
      render :action => 'edit'
    end
  end
  
  def print_patient_information
    @clinic = Clinic.find(params[:id])
    render :layout => 'print'
  end
  
  def check_token
    token_required( Clinic, params[:token], params[:id] )
  end
  
  def refresh_cache
    @clinic = Clinic.find(params[:id])
    @feedback = @clinic.feedback_items.build
    render :show, :layout => 'ajax'
  end
end
