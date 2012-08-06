class ReviewItemsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @review_items = ReviewItem.active
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def archived
    @review_items = ReviewItem.archived.order('id desc').paginate(:page => params[:page], :per_page => 30)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def destroy
    @review_item = ReviewItem.find(params[:id])
    @review_item.destroy
    redirect_to review_items_url, :notice => "Successfully discarded changes."
  end
end
