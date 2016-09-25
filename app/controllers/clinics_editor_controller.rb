class ClinicsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :require_authentication
  skip_authorization_check
  before_filter :check_pending, except: [:pending, :temp_edit, :temp_update]
  before_filter :check_token

  def edit
    @token = params[:token]
    @form_modifier = ClinicFormModifier.new(:edit, current_user, token: true)
    @clinic = Clinic.includes_clinic_locations.find(params[:id])
    @review_item = @clinic.review_item
    if @clinic.focuses.count == 0
      @clinic.focuses.build
    end
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
    @specializations_focuses =
      GenerateClinicFocusInputs.exec(@clinic, @clinic.specializations)
    BuildTeleservices.call(provider: @clinic)
    render template: 'clinics/edit'
  end

  def update
    @clinic = Clinic.find(params[:id])

    ReviewItem.delete(@clinic.review_item) if @clinic.review_item.present?

    review_item = ReviewItem.new
    review_item.item_type = "Clinic"
    review_item.item_id = @clinic.id
    review_item.base_object = params[:pre_edit_form_data]
    review_item.object = begin
      if params[:no_updates]
        params[:pre_edit_form_data]
      else
        params.delete(:pre_edit_form_data)
        ReviewItem.encode params
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
    @clinic = Clinic.find(params[:id])
  end

  def check_pending
    clinic = Clinic.find(params[:id])
    if clinic.review_item.present? && (
      !current_user || (clinic.review_item.editor != current_user)
    )
      redirect_to clinic_self_pending_path(id: clinic.id, token: params[:token])
    end
  end

  def check_token
    token_required( Clinic, params[:token], params[:id] )
  end
end
