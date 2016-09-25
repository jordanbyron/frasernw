class SpecialistsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :require_authentication
  skip_authorization_check
  before_filter :check_pending, except: [:pending, :temp_edit, :temp_update]
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
    BuildTeleservices.call(provider: @specialist)
    load_form_variables(:visible?)

    @specializations_clinics, @specializations_clinic_locations =
      GenerateClinicLocationInputs.exec(@specialist.specializations, :visible?)

    @specializations_capacities = GenerateSpecialistCapacityInputs.exec(
      @specialist,
      @specialist.specializations
    )
    @view = @specialist.views.build(notes: request.remote_ip)
    @view.save
    render template: 'specialists/edit'
  end

  def update
    @specialist = Specialist.find(params[:id])

    ReviewItem.delete(@specialist.review_item) if @specialist.review_item.present?

    review_item = ReviewItem.new
    review_item.item_type = "Specialist"
    review_item.item_id = @specialist.id
    review_item.base_object = params[:pre_edit_form_data]
    review_item.object = begin
      if params[:no_updates]
        params[:pre_edit_form_data]
      else
        params.delete(:pre_edit_form_data)
        ReviewItem.encode(params)
      end
    end
    review_item.set_edit_source!(current_user, params[:secret_token_id])
    review_item.status =
      params[:no_updates] ? ReviewItem::STATUS_NO_UPDATES: ReviewItem::STATUS_UPDATES
    review_item.save

    BuildReviewItemNote.new(
      params: params,
      current_user: current_user,
      review_item: review_item
    ).exec

    ReviewItemsMailer.user_edited(review_item).deliver

    render
  end

  def pending
    @specialist = Specialist.find(params[:id])
  end

  def check_pending
    specialist = Specialist.find(params[:id])
    if specialist.review_item.present? && (
      !current_user || (specialist.review_item.editor != current_user)
    )
      redirect_to specialist_self_pending_path(id: specialist.id, token: params[:token])
    end
  end

  def check_token
    token_required( Specialist, params[:token], params[:id] )
  end

  private

  def load_form_variables(scope = :presence)
    @offices = Office.all_formatted_for_form(scope: scope)
    @hospitals = Hospital.all_formatted_for_form(scope)
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
    end
  end

end
