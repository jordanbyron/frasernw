class ClinicsController < ApplicationController
  skip_before_filter :require_authentication, only: :refresh_cache
  load_and_authorize_resource except: [:refresh_cache, :create, :index_own]
  before_filter :check_token, only: :refresh_cache
  skip_authorization_check only: :refresh_cache
  include ApplicationHelper

  def index
    @model = ProfilesIndex.call(
      klass: Clinic,
      params: params,
      current_user: current_user
    )

    render "profiles/index"
  end

  def index_own
    authorize! :index_own, Clinic
    @clinics = current_user.user_controls_clinics
  end

  def show
    @clinic = Clinic.
      includes_location_data.
      includes(:specialists).
      includes(attendances: :specialist).
      includes(:review_item).
      find(params[:id])

    if @clinic.controlling_users.include?(current_user)
      current_user.viewed_controlled_clinic!(@clinic)
    end
  end

  def new
    @form_modifier = ClinicFormModifier.new(:new, current_user)
    @clinic = Clinic.new
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
    BuildTeleservices.call(provider: @clinic)
  end

  def create
    parsed_params = ParamParser::Clinic.new(params).exec
    @clinic = Clinic.new(parsed_params[:clinic])
    authorize! :create, @clinic
    if @clinic.save
      redirect_to clinic_path(@clinic),
        notice: "Successfully created #{@clinic.name}."
    else
      render action: 'new'
    end
  end

  def edit
    @form_modifier = ClinicFormModifier.new(:edit, current_user)
    @clinic = Clinic.includes_clinic_locations.find(params[:id])
    if @clinic.review_item.present?
      redirect_to @clinic,
        notice: "There are already changes awaiting review for this clinic."
    end
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
    BuildTeleservices.call(provider: @clinic)
  end

  def update
    @clinic = Clinic.find(params[:id])
    if @clinic.review_item.present?
      redirect_to @clinic,
        notice: "There are already changes awaiting review for this clinic."
    end
    ExpireFragment.call clinic_path(@clinic)

    parsed_params = ParamParser::Clinic.new(params).exec

    if @clinic.update_attributes(parsed_params[:clinic])
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
    @review_item = @clinic.review_item

    if @review_item.blank?
      redirect_to clinics_path,
        notice: "There is no current review item for this clinic."
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
      @secret_token_id =
        @clinic.review_item.decoded_review_object["clinic"]["secret_token_id"]
      BuildTeleservices.call(provider: @clinic)
      render template: 'clinics/edit'
    end
  end

  def rereview
    @clinic = Clinic.includes_clinic_locations.find(params[:id])
    @form_modifier = ClinicFormModifier.new(:rereview, current_user)
    @review_item = ReviewItem.find(params[:review_item_id])

    if @review_item.blank?
      redirect_to clinics_path,
        notice: "There is no current review item for this clinic."
    elsif @review_item.base_object.blank?
      redirect_to clinics_path,
        notice: "There is no profile for this clinic to re-review."
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
      @secret_token_id =
        @review_item.decoded_review_object["clinic"]["secret_token_id"]
      BuildTeleservices.call(provider: @clinic)
      render template: 'clinics/edit'
    end
  end

  def accept
    #accept changes, archive the review item so that we can save the clinic
    @clinic = Clinic.find(params[:id])

    review_item = @clinic.review_item
    review_item.archived = true
    review_item.save

    BuildReviewItemNote.new(
      params: params,
      current_user: current_user,
      review_item: review_item
    ).exec

    ExpireFragment.call clinic_path(@clinic)

    parsed_params = ParamParser::Clinic.new(params).exec

    # used instead of the documented way of passing controller metadata
    # bc you need to set that at the start of the request
    ::PaperTrail.controller_info = { review_item_id: review_item.id }

    if @clinic.update_attributes(parsed_params[:clinic])
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
        notice: "There is no current review item for this clinic."
    else
      review_item.archived = true
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
    render :show
  end
end
