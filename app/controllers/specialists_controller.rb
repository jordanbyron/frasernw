class SpecialistsController < ApplicationController
  skip_before_filter :login_required, :only => [:refresh_cache, :refresh_index_cache]
  load_and_authorize_resource :except => [:refresh_cache, :refresh_index_cache]
  before_filter :check_token, :only => :refresh_cache
  before_filter :check_specialization_token, :only => :refresh_index_cache
  skip_authorization_check :only => [:refresh_cache, :refresh_index_cache]
  include ApplicationHelper

  cache_sweeper :specialist_sweeper, :only => [:create, :update, :update_photo, :accept, :destroy]

  def index
    if params[:specialization_id].present?
      @specializations = [Specialization.find(params[:specialization_id])]
    else
      @specializations = Specialization.all
    end
    @all_divisions = Division.all
    @user_divisions = current_user_divisions
    @follow_path = begin
      if params[:specialization_id].present?
        just_partials_specialists_path(specialization_id: params[:specialization_id])
      else
        just_partials_specialists_path
      end
    end
    @selected_division = @user_divisions.first
  end

  def just_partials
    if params[:specialization_id].present?
      @specializations = [Specialization.find(params[:specialization_id])]
    else
      @specializations = Specialization.all
    end
    @user_divisions = current_user_divisions

    no_division_partial = render_to_string(
      partial: "no_division_partial",
      locals: {
        specializations: @specializations
      }
    )

    partials = Division.all.map do |division|
      {
        id: division.id,
        html: render_to_string(
          partial: "division_partial",
          locals: {
            user_divisions: @user_divisions,
            division: division,
            specializations: @specializations
          }
        )
      }
    end << {
      id: 0,
      html: no_division_partial
    }

    render json: {
      partials: partials
    }
  end

  def show
    @specialist = Specialist.cached_find(params[:id])
    @feedback = @specialist.active_feedback_items.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:new, current_user)
    #specialization passed in to facilitate javascript "checking off" of starting speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])
    @specialist = Specialist.new
    @specialist.specialist_specializations.build( :specialization_id => @specialization.id )

    build_specialist_offices

    @specializations_clinics, @specializations_clinic_locations =
      GenerateClinicLocationInputs.exec([ @specialization ])

    @capacities = GenerateSpecialistCapacityInputs.exec(
      nil,
      [ @specialization ]
    )
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    #can only have one of office_id or office_attributes, otherwise create gets confused
    params[:specialist][:specialist_offices_attributes].each{ |so_key, so_value|
      if so_value[:office_id].blank?
        so_value.delete(:office_id)
      else
        so_value.delete(:office_attributes)
      end
    }
    @specialist = Specialist.new(params[:specialist])
    if @specialist.save!
      if params[:capacities_mapped].present?
        specialist_specializations = @specialist.specializations
        params[:capacities_mapped].each do |checkbox_key, value|
          next unless value == "1"
          capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, checkbox_key)
          capacity.investigation = params[:capacities_investigations][checkbox_key]
          capacity.waittime_mask = params[:capacities_waittime][checkbox_key] if params[:capacities_waittime].present?
          capacity.lagtime_mask = params[:capacities_lagtime][checkbox_key] if params[:capacities_lagtime].present?
          capacity.save

          #save any other capacities that have the same procedure and are in a specialization our specialist is in
          capacity.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.map{ |ps2| Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, ps2.id) }.map{ |c| c.save }
        end
      end

      @specialist.save
      redirect_to @specialist, :notice => "Successfully created #{@specialist.name}. #{undo_link}"
    else
      render :action => 'new'
    end
  end

  def edit
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:edit, current_user)
    @specialist = Specialist.find(params[:id])
    if @specialist.capacities.count == 0
      @specialist.capacities.build
    end

    build_specialist_offices

    @specializations_clinics, @specializations_clinic_locations =
      GenerateClinicLocationInputs.exec(@specialist.specializations)

    @capacities = GenerateSpecialistCapacityInputs.exec(
      @specialist,
      @specialist.specializations
    )
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_update(@specialist)

    parsed_params = ParamParser::Specialist.new(params).exec
    if @specialist.update_attributes(parsed_params[:specialist])
      UpdateSpecialistCapacities.exec(@specialist, parsed_params)

      @specialist.save
      redirect_to @specialist, :notice => "Successfully updated #{@specialist.name}. #{undo_link}"
    else
      load_form_variables
      render :edit
    end
  end

  def accept
    #accept changes, archive the review item so that we can save the specialist
    @specialist = Specialist.find(params[:id])

    review_item = @specialist.review_item

    if review_item.blank?
      redirect_to specialist_path(@specialist), :notice => "There are no review items for this specialist"
    else
      review_item.archived = true;
      review_item.save

      BuildReviewItemNote.new(
        params: params,
        current_user: current_user,
        review_item: review_item
      ).exec

      SpecialistSweeper.instance.before_controller_update(@specialist)

      parsed_params = ParamParser::Specialist.new(params).exec
      if @specialist.update_attributes(parsed_params[:specialist])
        UpdateSpecialistCapacities.exec(@specialist, parsed_params)

        @specialist.save
        redirect_to @specialist, :notice => "Successfully updated #{@specialist.name}. #{undo_link}"
      else
        load_form_variables
        render :edit
      end
    end
  end

  def archive
    #archive the review item so that we can save the specialist
    @specialist = Specialist.find(params[:id])

    review_item = @specialist.review_item

    if review_item.blank?
      redirect_to specialist_path(@specialist), :notice => "There are no review items for this specialist"
    else
      review_item.archived = true;
      review_item.save
      redirect_to review_items_path, :notice => "Successfully archived review item for #{@specialist.name}."
    end
  end

  def destroy
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_destroy(@specialist)
    name = @specialist.name;
    @specialist.destroy
    redirect_to root_url, :notice => "Successfully deleted #{name}. #{undo_link}"
  end

  def undo_link
    #view_context.link_to("undo", revert_version_path(@specialist.versions.scoped.last), :method => :post).html_safe
  end

  def review
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:review, current_user)
    @specialist = Specialist.find(params[:id])
    @review_item = @specialist.review_item;

    if @review_item.blank?
      redirect_to specialists_path, :notice => "There are no review items for this specialist"
      else

      build_specialist_offices

      @specializations_clinics, @specializations_clinic_locations =
        GenerateClinicLocationInputs.exec(@specialist.specializations)

      @capacities = GenerateSpecialistCapacityInputs.exec(
        @specialist,
        @specialist.specializations
      )
      render :template => 'specialists/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true
    end
  end

  def rereview
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:rereview, current_user)
    @specialist = Specialist.find(params[:id])
    @review_item = ReviewItem.find(params[:review_item_id])

    if @review_item.blank?
      redirect_to specialists_path, :notice => "There are no review items for this specialist"
    elsif @review_item.base_object.blank?
      redirect_to specialists_path, :notice => "There is no base review item for this specialist to re-review from"
    else

      build_specialist_offices

      @specializations_clinics, @specializations_clinic_locations =
        GenerateClinicLocationInputs.exec(@specialist.specializations)

      @capacities = GenerateSpecialistCapacityInputs.exec(
        @specialist,
        @specialist.specializations
      )
      render :template => 'specialists/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true
    end
  end

  def print_patient_information
    @specialist = Specialist.cached_find(params[:id])
    @specialist_office = @specialist.specialist_offices.reject{ |so| so.empty? }.first
    render :layout => 'print'
  end

  def print_office_patient_information
    @specialist = Specialist.cached_find(params[:id])
    @specialist_office = SpecialistOffice.find(params[:office_id])
    render :print_patient_information, :layout => 'print'
  end

  def photo
    @specialist = Specialist.cached_find(params[:id])
    render :layout => request.headers['X-PJAX'] ? 'ajax' : true
  end

  def update_photo
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_update(@specialist)
    if @specialist.update_attributes(params[:specialist])
      redirect_to @specialist, :notice  => "Successfully updated #{@specialist.formal_name}'s photo."
    else
      render :action => 'photo'
    end
  end

  def check_token
    token_required( Specialist, params[:token], params[:id] )
  end

  def check_specialization_token
    token_required( Specialization, params[:token], params[:specialization_id])
  end

  def refresh_cache
    @specialist = Specialist.find(params[:id])
    @specialist.flush_cached_find
    @specialist = Specialist.cached_find(params[:id])
    @feedback = @specialist.active_feedback_items.build
    render :show, :layout => 'ajax'
  end

  #TO DO make this work to reload cache with pathways:recache:specialists_index
  def refresh_index_cache
    if params[:specialization_id].present?
      @specializations = [Specialization.find(params[:specialization_id])]
    else
      @specializations = Specialization.all
    end

    if params[:division_id].present?
      @user_divisions = [Division.find(params[:division_id])]
    else
      @user_divisions = Division.all
    end
    @all_divisions = Division.all
    @first_division = @user_divisions.first
    render :index, :layout => 'ajax'
  end

  private

  def load_form_variables
    @offices = Office.cached_all_formatted_for_form
    @hospitals = Hospital.all_formatted_for_form
  end

  def build_specialist_offices
    # build office & phone schedule, build address only with a new entry.
    while @specialist.specialist_offices.length < Specialist::MAX_OFFICES
      so = @specialist.specialist_offices.build
      s = so.build_phone_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      o = so.build_office
      l = o.build_location
      l.build_address if @form_modifier.new_record?
    end
  end
end
