class FeedbackItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @feedback_items = FeedbackItem.active
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def archived
    @feedback_items = FeedbackItem.archived.order('id desc').paginate(:page => params[:page], :per_page => 30)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @feedback_item = FeedbackItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @feedback_item = FeedbackItem.new(params[:feedback_item])
    @feedback_item.user = current_user
    @feedback_item.save
    if @feedback_item.item.is_a? ScItem
      EventMailer.mail_content_item_feedback(@feedback_item).deliver
    else
      EventMailer.mail_specialist_clinic_feedback(@feedback_item).deliver
    end
  end

  def destroy
    #we actually archive
    @feedback_item = FeedbackItem.find(params[:id])
    @feedback_item.archived = true
    @feedback_item.save
    redirect_to feedback_items_url, :notice => "Successfully archived feedback item."
  end
end
