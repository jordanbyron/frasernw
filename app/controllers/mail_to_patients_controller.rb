class MailToPatientsController < ApplicationController
  skip_authorization_check

  def new
    @user = current_user
    @sc_item = ScItem.find(params[:id])
  end

  def create
    if params.blank? || params[:patient_email].blank? || params[:sc_item_id].blank?
      redirect_to root_url
    elsif !ValidatesEmailFormatOf::validate_email_format(params[:patient_email]).nil?
      redirect_to compose_mail_to_patients_path(ScItem.find(params[:sc_item_id])),
        alert: "Email address does not appear to be valid"
    else
      @sc_item = ScItem.find(params[:sc_item_id])
      @patient_email = params[:patient_email]
      @sc_item.mail_to_patient(current_user, @patient_email)
      ScItemMailing.create(
        sc_item_id: @sc_item.id,
        user_id: current_user.id,
        user_division_ids: current_user.divisions.map(&:id),
        user_role: current_user.role
      )
      redirect_to origin_path(params[:print_request_origin]),
        alert: "Successfully sent e-mail to patient."
    end
  end
end
