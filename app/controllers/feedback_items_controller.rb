class FeedbackItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @feedback_items = FeedbackItem.active
  end

  def archived
    @divisions_scope =
      current_user.as_admin_or_super? ? Division.all : current_user.as_divisions
    @feedback_items = FeedbackItem.
      archived.
      order('id desc').
      select{|item| item.for_divisions?(@divisions_scope) }.
      paginate(page: params[:page], per_page: 30)

    @categorized_feedback_items = {
      Specialist => @feedback_items.
        select{ |feedback_item| feedback_item.item.is_a?(Specialist) },
      Clinic => @feedback_items.
        select{ |feedback_item| feedback_item.item.is_a?(Clinic) },
      ScItem => @feedback_items.
        select{ |feedback_item| feedback_item.item.is_a?(ScItem) }
    }
  end

  def show
    @feedback_item = FeedbackItem.find(params[:id])
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

    render nothing: true, status: 200
  end

  def destroy
    #we actually archive
    @feedback_item = FeedbackItem.find(params[:id])
    @feedback_item.archived = true
    @feedback_item.save
    redirect_to feedback_items_url,
      notice: "Successfully archived feedback item."
  end
end
