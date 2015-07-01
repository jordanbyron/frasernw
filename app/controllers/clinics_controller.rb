class ClinicsController < ApplicationController
  skip_before_filter :login_required, :only => :refresh_cache
  load_and_authorize_resource :except => :refresh_cache
  before_filter :check_token, :only => :refresh_cache
  skip_authorization_check :only => :refresh_cache
  include ApplicationHelper

  cache_sweeper :clinic_sweeper, :only => [:create, :update, :destroy]

  def index
    if params[:specialization_id].present?
      @specializations = [Specialization.find(params[:specialization_id])]
    else
      @specializations = Specialization.all
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @clinic = Clinic.find(params[:id])
    @feedback = @clinic.feedback_items.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @form_modifier = ClinicFormModifier.new(:new, current_user)
    #specialization passed in to facilitate javascript "checking off" of starting speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])
    @clinic = Clinic.new
    @clinic.clinic_specializations.build( :specialization_id => @specialization.id )
    while @clinic.clinic_locations.length < Clinic::MAX_LOCATIONS
      cl = @clinic.clinic_locations.build
      s = cl.build_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      l = cl.build_location
      l.build_address
    end
    @clinic.attendances.build
    @clinic_procedures = ancestry_options( @specialization.non_assumed_procedure_specializations_arranged )
    @clinic_specialists = @specialization.specialists.collect { |s| [s.name, s.id] }
    @focuses = []
    @specialization.non_assumed_procedure_specializations_arranged.each { |ps, children|
      @focuses << generate_focus(nil, ps, 0)
      children.each { |child_ps, grandchildren|
        @focuses << generate_focus(nil, child_ps, 1)
        grandchildren.each { |grandchild_ps, greatgrandchildren|
          @focuses << generate_focus(nil, grandchild_ps, 2)
        }
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @clinic = Clinic.new(params[:clinic])
    if @clinic.save
      if params[:focuses_mapped].present?
        clinic_specializations = @clinic.specializations
        params[:focuses_mapped].each do |updated_focus, value|
          focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, updated_focus)
          focus.investigation = params[:focuses_investigations][updated_focus]
          focus.waittime_mask = params[:focuses_waittime][updated_focus] if params[:focuses_waittime].present?
          focus.lagtime_mask = params[:focuses_lagtime][updated_focus] if params[:focuses_lagtime].present?
          focus.save

          #save any other focuses that have the same procedure and are in a specialization our clinic is in
          focus.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.map{ |ps2| Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, ps2.id) }.map{ |f| f.save }
        end
      end
      ## TODO: remove when we're certain the new review system is working
      params.delete(:pre_edit_form_data)
      @clinic.review_object = ActiveSupport::JSON::encode(params)

      @clinic.save
      redirect_to clinic_path(@clinic), :notice => "Successfully created #{@clinic.name}."
    else
      render :action => 'new'
    end
  end

  def edit
    @form_modifier = ClinicFormModifier.new(:edit, current_user)
    @clinic = Clinic.find(params[:id])
    while @clinic.clinic_locations.length < Clinic::MAX_LOCATIONS
      puts "location #{@clinic.clinic_locations.length}"
      cl = @clinic.clinic_locations.build
      s = cl.build_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      l = cl.build_location
      l.build_address
      puts "locations #{@clinic.locations.length}"
    end
    @clinic_procedures = []
    @clinic.specializations.each { |specialization|
      @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
      @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
    }
    @clinic_specialists = []
    procedure_specializations = {}
    @clinic.specializations.each { |specialization|
      @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
      @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
      procedure_specializations.merge!(specialization.non_assumed_procedure_specializations_arranged)
    }
    focuses_procedure_list = []
    @focuses = []
    procedure_specializations.each { |ps, children|
      if !focuses_procedure_list.include?(ps.procedure.id)
        @focuses << generate_focus(@clinic, ps, 0)
        focuses_procedure_list << ps.procedure.id
      end
      children.each { |child_ps, grandchildren|
        if !focuses_procedure_list.include?(child_ps.procedure.id)
          @focuses << generate_focus(@clinic, child_ps, 1)
          focuses_procedure_list << child_ps.procedure.id
        end
        grandchildren.each { |grandchild_ps, greatgrandchildren|
          if !focuses_procedure_list.include?(grandchild_ps.procedure.id)
            @focuses << generate_focus(@clinic, grandchild_ps, 2)
            focuses_procedure_list << grandchild_ps.procedure.id
          end
        }
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    params[:clinic][:procedure_ids] ||= []
    @clinic = Clinic.find(params[:id])
    ClinicSweeper.instance.before_controller_update(@clinic)

    parsed_params = ParamParser::Clinic.new(params).exec
    if @clinic.update_attributes(parsed_params[:clinic])
      clinic_specializations = @clinic.specializations
      if params[:focuses_mapped].present?
        @clinic.focuses.each do |original_focus|
          Focus.destroy(original_focus.id) if params[:focuses_mapped][original_focus.procedure_specialization.id.to_s].blank?
        end
        params[:focuses_mapped].each do |updated_focus, value|
          focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, updated_focus)
          focus.investigation = params[:focuses_investigations][updated_focus]
          focus.waittime_mask = params[:focuses_waittime][updated_focus] if params[:focuses_waittime].present?
          focus.lagtime_mask = params[:focuses_lagtime][updated_focus] if params[:focuses_lagtime].present?
          focus.save

          #save any other focuses that have the same procedure and are in a specialization our clinic is in
          focus.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.map{ |ps2| Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, ps2.id) }.map{ |f| f.save }
        end
      end
      ## TODO: remove when we're certain the new review system is working
      params.delete(:pre_edit_form_data)
      @clinic.review_object = ActiveSupport::JSON::encode(params)
      @clinic.save
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

  def review
    @clinic = Clinic.find(params[:id])
    @form_modifier = ClinicFormModifier.new(:review, current_user)
    @review_item = @clinic.review_item;

    if @review_item.blank?
      redirect_to clinics_path, :notice => "There are no review items for this specialist"
    else
      while @clinic.clinic_locations.length < Clinic::MAX_LOCATIONS
        cl = @clinic.clinic_locations.build
        s = cl.build_schedule
        s.build_monday
        s.build_tuesday
        s.build_wednesday
        s.build_thursday
        s.build_friday
        s.build_saturday
        s.build_sunday
        l = cl.build_location
        l.build_address
      end
      @clinic_procedures = []
      @clinic.specializations.each { |specialization|
        @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
        @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
      }
      @clinic_specialists = []
      procedure_specializations = {}
      @clinic.specializations.each { |specialization|
        @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
        @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
        procedure_specializations.merge!(specialization.non_assumed_procedure_specializations_arranged)
      }
      focuses_procedure_list = []
      @focuses = []
      procedure_specializations.each { |ps, children|
        if !focuses_procedure_list.include?(ps.procedure.id)
          @focuses << generate_focus(@clinic, ps, 0)
          focuses_procedure_list << ps.procedure.id
        end
        children.each { |child_ps, grandchildren|
          if !focuses_procedure_list.include?(child_ps.procedure.id)
            @focuses << generate_focus(@clinic, child_ps, 1)
            focuses_procedure_list << child_ps.procedure.id
          end
          grandchildren.each { |grandchild_ps, greatgrandchildren|
            if !focuses_procedure_list.include?(grandchild_ps.procedure.id)
              @focuses << generate_focus(@clinic, grandchild_ps, 2)
              focuses_procedure_list << grandchild_ps.procedure.id
            end
          }
        }
      }
      render :template => 'clinics/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true
    end
  end

  def rereview
    @clinic = Clinic.find(params[:id])
    @form_modifier = ClinicFormModifier.new(:rereview, current_user)
    @review_item = ReviewItem.find(params[:review_item_id])

    if @review_item.blank?
      redirect_to clinics_path, :notice => "There are no review items for this clinic"
    elsif @review_item.base_object.blank?
      redirect_to specialists_path, :notice => "There is no base review item for this clinic to re-review from"
    else
      while @clinic.clinic_locations.length < Clinic::MAX_LOCATIONS
        cl = @clinic.clinic_locations.build
        s = cl.build_schedule
        s.build_monday
        s.build_tuesday
        s.build_wednesday
        s.build_thursday
        s.build_friday
        s.build_saturday
        s.build_sunday
        l = cl.build_location
        l.build_address
      end
      @clinic_procedures = []
      @clinic.specializations.each { |specialization|
        @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
        @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
      }
      @clinic_specialists = []
      procedure_specializations = {}
      @clinic.specializations.each { |specialization|
        @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
        @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
        procedure_specializations.merge!(specialization.non_assumed_procedure_specializations_arranged)
      }
      focuses_procedure_list = []
      @focuses = []
      procedure_specializations.each { |ps, children|
        if !focuses_procedure_list.include?(ps.procedure.id)
          @focuses << generate_focus(@clinic, ps, 0)
          focuses_procedure_list << ps.procedure.id
        end
        children.each { |child_ps, grandchildren|
          if !focuses_procedure_list.include?(child_ps.procedure.id)
            @focuses << generate_focus(@clinic, child_ps, 1)
            focuses_procedure_list << child_ps.procedure.id
          end
          grandchildren.each { |grandchild_ps, greatgrandchildren|
            if !focuses_procedure_list.include?(grandchild_ps.procedure.id)
              @focuses << generate_focus(@clinic, grandchild_ps, 2)
              focuses_procedure_list << grandchild_ps.procedure.id
            end
          }
        }
      }
      render :template => 'clinics/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true
    end
  end

  def accept
    #accept changes, archive the review item so that we can save the clinic
    @clinic = Clinic.find(params[:id])

    review_item = @clinic.review_item
    review_item.archived = true;
    review_item.save

    ClinicSweeper.instance.before_controller_update(@clinic)

    parsed_params = ParamParser::Clinic.new(params).exec
    if @clinic.update_attributes(parsed_params[:clinic])
      clinic_specializations = @clinic.specializations
      if params[:focuses_mapped].present?
        @clinic.focuses.each do |original_focus|
          Focus.destroy(original_focus.id) if params[:focuses_mapped][original_focus.procedure_specialization.id.to_s].blank?
        end
        params[:focuses_mapped].each do |updated_focus, value|
          focus = Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, updated_focus)
          focus.investigation = params[:focuses_investigations][updated_focus]
          focus.waittime_mask = params[:focuses_waittime][updated_focus] if params[:focuses_waittime].present?
          focus.lagtime_mask = params[:focuses_lagtime][updated_focus] if params[:focuses_lagtime].present?
          focus.save

          #save any other focuses that have the same procedure and are in a specialization our clinic is in
          focus.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.map{ |ps2| Focus.find_or_create_by_clinic_id_and_procedure_specialization_id(@clinic.id, ps2.id) }.map{ |f| f.save }
        end
      end
      ## TODO: remove when we're certain the new review system is working
      params.delete(:pre_edit_form_data)
      @clinic.review_object = ActiveSupport::JSON::encode(params)

      @clinic.save
      redirect_to @clinic, :notice  => "Successfully updated #{@clinic.name}."
    else
      render :action => 'edit'
    end
  end

  def archive
    #archive the review item so that we can save the clinic
    @clinic = Clinic.find(params[:id])

    review_item = @clinic.review_item

    if review_item.blank?
      redirect_to clinic_path(@clinic), :notice => "There are no review items for this clinic"
    else
      review_item.archived = true;
      review_item.save
      redirect_to review_items_path, :notice => "Successfully archived review item for #{@clinic.name}."
    end
  end

  def print_patient_information
    @clinic = Clinic.find(params[:id])
    @clinic_location = @clinic.clinic_locations.reject{ |cl| cl.empty? }.first
    render :layout => 'print'
  end

  def print_location_patient_information
    @clinic = Clinic.find(params[:id])
    @clinic_location = ClinicLocation.find(params[:location_id])
    render :print_patient_information, :layout => 'print'
  end

  def check_token
    token_required( Clinic, params[:token], params[:id] )
  end

  def refresh_cache
    @clinic = Clinic.find(params[:id])
    @feedback = @clinic.feedback_items.build
    render :show, :layout => 'ajax'
  end

  protected

  def generate_focus(clinic, procedure_specialization, offset)
    focus = clinic.present? ? Focus.find_by_clinic_id_and_procedure_specialization_id(clinic.id, procedure_specialization.id) : nil
    return {
      :mapped => focus.present?,
      :name => procedure_specialization.procedure.name,
      :id => procedure_specialization.id,
      :investigations => focus.present? ? focus.investigation : "",
      :custom_wait_time => procedure_specialization.clinic_wait_time?,
      :waittime => focus.present? ? focus.waittime_mask : 0,
      :lagtime => focus.present? ? focus.lagtime_mask : 0,
      :offset => offset
    }
  end
end
