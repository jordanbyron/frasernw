class ClinicsController < ApplicationController
  skip_before_filter :require_authentication, only: :refresh_cache
  load_and_authorize_resource except: [:refresh_cache, :create]
  before_filter :check_token, only: :refresh_cache
  skip_authorization_check only: :refresh_cache
  include ApplicationHelper

  def index
    if params[:specialization_id].present?
      @specializations = [Specialization.find(params[:specialization_id])]
    else
      @specializations = Specialization.all
    end
    render layout: 'ajax' if request.headers['X-PJAX']
  end

  def show
    @clinic = Clinic.
      includes_location_data.
      includes(:specialists).
      includes(attendances: :specialist).
      includes(:review_item).
      find(params[:id])

    @feedback = @clinic.active_feedback_items.build

    if @clinic.controlling_users.include?(current_user)
      current_user.viewed_controlled_clinic!(@clinic)
    end
  end

  def new
    @form_modifier = ClinicFormModifier.new(:new, current_user)
    # specialization passed in to facilitate javascript "checking off" of starting
    # speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])
    @clinic = Clinic.new
    @clinic.clinic_specializations.build(specialization_id: @specialization.id)
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
    @clinic_specialists = @specialization.specialists.collect do |s|
      [s.name, s.id]
    end
    @specializations_focuses = GenerateClinicFocusInputs.exec(nil, [@specialization])
    BuildTeleservices.call(provider: @clinic)
    render layout: 'ajax' if request.headers['X-PJAX']
  end

  def create
    parsed_params = ParamParser::Clinic.new(params).exec
    @clinic = Clinic.new(parsed_params[:clinic])
    authorize! :create, @clinic
    if @clinic.save
      if params[:focuses_mapped].present?
        clinic_specializations = @clinic.specializations
        params[:focuses_mapped].select do |checkbox_key, value|
          value == "1"
        end.each do |checkbox_key, value|
          focus = Focus.find_or_create_by(
            clinic_id: @clinic.id, procedure_specialization_id: checkbox_key
          )
          focus.investigation = params[:focuses_investigations][checkbox_key]
          if params[:focuses_waittime].present?
            focus.waittime_mask = params[:focuses_waittime][checkbox_key]
          end
          if params[:focuses_lagtime].present?
            focus.lagtime_mask = params[:focuses_lagtime][checkbox_key]
          end
          focus.save

          # save any other focuses that have the same procedure and are in a
          # specialization our clinic is in
          focus.
            procedure_specialization.
            procedure.
            procedure_specializations.
            reject{ |ps2| !clinic_specializations.include?(ps2.specialization) }.
            map{ |ps2|
              Focus.find_or_create_by(
                clinic_id: @clinic.id, procedure_specialization_id: ps2.id
              )
            }.
            map{ |f| f.save }
        end
      end

      @clinic.save
      redirect_to clinic_path(@clinic), notice: "Successfully created #{@clinic.name}."
    else
      render action: 'new'
    end
  end

  def edit
    @form_modifier = ClinicFormModifier.new(:edit, current_user)
    @clinic = Clinic.includes_clinic_locations.find(params[:id])
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
    @clinic_specialists = GenerateClinicSpecialistInputs.exec(@clinic)
    @specializations_focuses =
      GenerateClinicFocusInputs.exec(@clinic, @clinic.specializations)
    BuildTeleservices.call(provider: @clinic)
    render layout: 'ajax' if request.headers['X-PJAX']
  end

  def update
    params[:clinic][:procedure_ids] ||= []
    @clinic = Clinic.find(params[:id])
    ExpireFragment.call clinic_path(@clinic)

    parsed_params = ParamParser::Clinic.new(params).exec
    if @clinic.update_attributes(parsed_params[:clinic])
      UpdateClinicFocuses.exec(@clinic, parsed_params)
      @clinic.save
      redirect_to @clinic, notice: "Successfully updated #{@clinic.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    @clinic = Clinic.find(params[:id])
    if @clinic.specialists_with_offices_in.any?
      render :attempted_delete
    else
      ExpireFragment.call clinic_path(@clinic)
      name = @clinic.name
      @clinic.destroy
      redirect_to clinics_url, notice: "Successfully deleted #{name}."
    end
  end

  def review
    @clinic = Clinic.includes_clinic_locations.find(params[:id])
    @form_modifier = ClinicFormModifier.new(:review, current_user)
    @review_item = @clinic.review_item;

    if @review_item.blank?
      redirect_to clinics_path, notice: "There are no review items for this specialist"
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

      @clinic_specialists = GenerateClinicSpecialistInputs.exec(@clinic)
      @specializations_focuses = GenerateClinicFocusInputs.exec(
        @clinic,
        @clinic.specializations
      )
      @secret_token_id =
        @clinic.review_item.decoded_review_object["clinic"]["secret_token_id"]
      BuildTeleservices.call(provider: @clinic)
      render template: 'clinics/edit', layout: request.headers['X-PJAX'] ? 'ajax' : true
    end
  end

  def rereview
    @clinic = Clinic.includes_clinic_locations.find(params[:id])
    @form_modifier = ClinicFormModifier.new(:rereview, current_user)
    @review_item = ReviewItem.find(params[:review_item_id])

    if @review_item.blank?
      redirect_to clinics_path, notice: "There are no review items for this clinic"
    elsif @review_item.base_object.blank?
      redirect_to specialists_path,
        notice: "There is no base review item for this clinic to re-review from"
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
      @clinic_specialists = GenerateClinicSpecialistInputs.exec(@clinic)
      @specializations_focuses = GenerateClinicFocusInputs.exec(
        @clinic,
        @clinic.specializations
      )
      @secret_token_id = @review_item.decoded_review_object["clinic"]["secret_token_id"]
      BuildTeleservices.call(provider: @clinic)
      render template: 'clinics/edit', layout: request.headers['X-PJAX'] ? 'ajax' : true
    end
  end

  def accept
    #accept changes, archive the review item so that we can save the clinic
    @clinic = Clinic.find(params[:id])

    review_item = @clinic.review_item
    review_item.archived = true;
    review_item.save

    BuildReviewItemNote.new(
      params: params,
      current_user: current_user,
      review_item: review_item
    ).exec

    ExpireFragment.call clinic_path(@clinic)

    parsed_params = ParamParser::Clinic.new(params).exec
    if @clinic.update_attributes(parsed_params[:clinic])
      UpdateClinicFocuses.exec(@clinic, parsed_params)
      @clinic.reload.versions.last.update_attributes(review_item_id: review_item.id)
      @clinic.save
      redirect_to @clinic, notice: "Successfully updated #{@clinic.name}."
    else
      BuildTeleservices.call(provider: @clinic)
      render action: 'edit'
    end
  end

  def archive
    #archive the review item so that we can save the clinic
    @clinic = Clinic.find(params[:id])

    review_item = @clinic.review_item

    if review_item.blank?
      redirect_to clinic_path(@clinic),
        notice: "There are no review items for this clinic"
    else
      review_item.archived = true;
      review_item.save
      redirect_to review_items_path,
        notice: "Successfully archived review item for #{@clinic.name}."
    end
  end

  def print_location_information
    @clinic = Clinic.find(params[:id])
    @clinic_location = ClinicLocation.find(params[:location_id])
    render :print_information, layout: 'print'
  end

  def check_token
    token_required( Clinic, params[:token], params[:id] )
  end

  def refresh_cache
    @clinic = Clinic.find(params[:id])
    @feedback = @clinic.active_feedback_items.build
    render :show, layout: 'ajax'
  end
end
