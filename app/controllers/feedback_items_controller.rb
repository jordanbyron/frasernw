class FeedbackItemsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @feedback_items = FeedbackItem.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @feedback_item = FeedbackItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @feedback_item = FeedbackItem.new(params[:feedback_item])
    @feedback_item.user = current_user
    if @feedback_item.save
      redirect_to @feedback_item
    else
      render :action => 'new', :layout => 'ajax' if request.headers['X-PJAX']
    end
  end
  
  def destroy
    @feedback_item = FeedbackItem.find(params[:id])
    @feedback_item.destroy
    redirect_to feedback_items_url, :notice => "Successfully deleted feedback_item."
  end
end
