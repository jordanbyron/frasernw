class SpecialistsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :login_required
  skip_authorization_check
  before_filter :check_pending, :except => [:pending, :temp_edit, :temp_update]
  before_filter :check_token

  def edit
    @token = params[:token]
    @form_modifier = SpecialistFormModifier.new(:edit, current_user, token: true)
    @specialist = Specialist.find(params[:id])
    @review_item = @specialist.review_item
    if @specialist.capacities.count == 0
      @specialist.capacities.build
    end

    build_specialist_offices
    load_form_variables(:visible?)

    @specializations_clinics, @specializations_clinic_locations =
      GenerateClinicLocationInputs.exec(@specialist.specializations)

    @capacities = GenerateSpecialistCapacityInputs.exec(
      @specialist,
      @specialist.specializations
    )
    @view = @specialist.views.build(:notes => request.remote_ip)
    @view.save
    if request.headers['X-PJAX']
      render :template => 'specialists/edit', :layout => 'ajax'
    else
      render :template => 'specialists/edit'
    end
  end

  def update
    @specialist = Specialist.find(params[:id])

    ReviewItem.delete(@specialist.review_item) if @specialist.review_item.present?

    review_item = ReviewItem.new
    review_item.item_type = "Specialist"
    review_item.item_id = @specialist.id
    review_item.base_object = params.delete(:pre_edit_form_data)
    review_item.object = ActiveSupport::JSON::encode(params)
    review_item.whodunnit = current_user.id if current_user.present?
    review_item.status = params[:no_updates] ? ReviewItem::STATUS_NO_UPDATES: ReviewItem::STATUS_UPDATES
    review_item.save

    BuildReviewItemNote.new(
      params: params,
      current_user: current_user,
      review_item: review_item
    ).exec

    EventMailer.mail_review_queue_entry(review_item).deliver

    render
  end

  def pending
    @specialist = Specialist.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def check_pending
    specialist = Specialist.find(params[:id])
    redirect_to specialist_self_pending_path(specialist) if specialist.review_item.present? && (!current_user || (specialist.review_item.whodunnit != current_user.id.to_s))
  end

  def check_token
    token_required( Specialist, params[:token], params[:id] )
  end

  private

  def load_form_variables(hospital_scope = :presence)
    @offices = Office.cached_all_formatted_for_form
    @hospitals = Hospital.all_formatted_for_form(hospital_scope)
  end

  def build_specialist_offices
    # build office & phone schedule.
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
    end
  end

end
