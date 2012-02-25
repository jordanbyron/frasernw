class ReviewItemsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @review_items = ReviewItem.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @review_item = ReviewItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
end
