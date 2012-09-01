class MailToPatientsController < ApplicationController
  skip_authorization_check
  
  def new  
    @user = current_user
    @sc_item = ScItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end  
  
  def create  
    if params.blank? || params[:patient_email].blank? || params[:sc_item_id].blank?
      redirect_to root_url
    else
      @sc_item = ScItem.find(params[:sc_item_id])
      @patient_email = params[:patient_email]
      @sc_item.mail_to_patient(current_user, @patient_email)
      redirect_to @sc_item, :alert => "Successfully e-mailed to #{@patient_email}."
    end
  end  
end
