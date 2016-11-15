class SpecialistsController < ApplicationController
  skip_before_filter :require_authentication,
    only: [:refresh_cache]
  load_and_authorize_resource except: [
    :refresh_cache,
    :create
  ]
  before_filter :check_token, only: :refresh_cache
  skip_authorization_check only: [:refresh_cache]
  include ApplicationHelper

  def index
    @model = ProfilesIndex.call(
      klass: Specialist,
      params: params,
      current_user: current_user
    )

    render "profiles/index"
  end

  def show
    @specialist = Specialist.cached_find(params[:id])
    if @specialist.controlling_users.include?(current_user)
      current_user.viewed_controlled_specialist!(@specialist)
    end
  end

  def new
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:new, current_user)
    # specialization passed in to facilitate javascript "checking off" of
    # starting speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])
    @specialist = Specialist.new
    @specialist.
      specialist_specializations.
      build(specialization_id: @specialization.id)

    BuildTeleservices.call(provider: @specialist)
    build_specialist_offices

    @specializations_clinics, @specializations_clinic_locations =
      GenerateClinicLocationInputs.exec([ @specialization ])
  end

  def create
    parsed_params = ParamParser::Specialist::Create.new(params).exec
    @specialist = Specialist.new(parsed_params[:specialist])
    authorize! :create, @specialist
    if @specialist.save!
      redirect_to @specialist,
        notice: "Successfully created #{@specialist.name}."
    else
      render action: 'new'
    end
  end

  def edit
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:edit, current_user)
    @specialist = Specialist.find(params[:id])
    if @specialist.review_item.present?
      redirect_to @specialist,
        notice: "There are already changes awaiting review for this specialist."
    end
    BuildTeleservices.call(provider: @specialist)

    build_specialist_offices

    @specializations_clinics, @specializations_clinic_locations =
      GenerateClinicLocationInputs.exec(@specialist.specializations)
  end

  def update
    @specialist = Specialist.find(params[:id])
    if @specialist.review_item.present?
      redirect_to @specialist,
        notice: "There are already changes awaiting review for this specialist."
    end
    ExpireFragment.call specialist_path(@specialist)

    parsed_params = ParamParser::Specialist.new(params).exec
    if @specialist.update_attributes(parsed_params[:specialist])

      redirect_to @specialist,
        notice: "Successfully updated #{@specialist.name}."
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
      redirect_to specialist_path(@specialist),
        notice: "There is no current review item for this specialist."
    else
      review_item.archived = true;
      review_item.save

      BuildReviewItemNote.new(
        params: params,
        current_user: current_user,
        review_item: review_item
      ).exec

      ExpireFragment.call specialist_path(@specialist)

      parsed_params = ParamParser::Specialist.new(params).exec

      # used instead of the documented way of passing controller metadata
      # bc you need to set that at the start of the request
      ::PaperTrail.controller_info = { review_item_id: review_item.id }

      if @specialist.update_attributes(parsed_params[:specialist])
        redirect_to @specialist,
          notice: "Successfully updated #{@specialist.name}."
      else
        BuildTeleservices.call(provider: @specialist)
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
      redirect_to specialist_path(@specialist),
        notice: "There is no current review item for this specialist."
    else
      review_item.archived = true;
      review_item.save
      redirect_to review_items_path,
        notice: "Successfully archived review item for #{@specialist.name}."
    end
  end

  def destroy
    @specialist = Specialist.find(params[:id])
    ExpireFragment.call specialist_path(@specialist)
    name = @specialist.name;
    @specialist.destroy
    redirect_to root_url, notice: "Successfully deleted #{name}."
  end

  def review
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:review, current_user)
    @specialist = Specialist.find(params[:id])
    @review_item = @specialist.review_item

    if @review_item.blank?
      redirect_to root_path,
        notice: "There is no current review item for this specialist."
    else
      build_specialist_offices

      @specializations_clinics, @specializations_clinic_locations =
        GenerateClinicLocationInputs.exec(@specialist.specializations)

      @secret_token_id =
        @specialist.
          review_item.
          decoded_review_object["specialist"]["secret_token_id"]
      BuildTeleservices.call(provider: @specialist)
      render template: 'specialists/edit'
    end
  end

  def rereview
    load_form_variables
    @form_modifier = SpecialistFormModifier.new(:rereview, current_user)
    @specialist = Specialist.find(params[:id])
    @review_item = ReviewItem.find(params[:review_item_id])

    if @review_item.blank?
      redirect_to root_path,
        notice: "There is no current review item for this specialist."
    elsif @review_item.base_object.blank?
      redirect_to root_path,
        notice: "There is no profile for this specialist to re-review."
    else

      build_specialist_offices

      @specializations_clinics, @specializations_clinic_locations =
        GenerateClinicLocationInputs.exec(@specialist.specializations)
      @secret_token_id =
        @review_item.decoded_review_object["specialist"]["secret_token_id"]
      BuildTeleservices.call(provider: @specialist)
      render template: 'specialists/edit'
    end
  end

  def print_office_information
    @specialist = Specialist.cached_find(params[:id])
    @specialist_office = SpecialistOffice.find(params[:office_id])
    render :print_information, layout: 'print'
  end

  def print_clinic_information
    @specialist = Specialist.cached_find(params[:id])
    @clinic = Clinic.find(params[:clinic_id])
    @clinic_location = ClinicLocation.find(params[:location_id])
    render :print_information, layout: 'print'
  end

  def photo
    @specialist = Specialist.cached_find(params[:id])
  end

  def update_photo
    @specialist = Specialist.find(params[:id])
    ExpireFragment.call specialist_path(@specialist)
    if @specialist.update_attributes(params[:specialist])
      redirect_to @specialist,
        notice: "Successfully updated #{@specialist.formal_name}'s photo."
    else
      render action: 'photo'
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
    @specialist.expire_cache
    @specialist = Specialist.cached_find(params[:id])
    render :show
  end

  private

  def load_form_variables
    @offices = Office.all_formatted_for_form
    @hospitals = Hospital.all_formatted_for_form
  end

  def build_specialist_offices
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
      l.build_address if so.new_record?
    end
  end
end
