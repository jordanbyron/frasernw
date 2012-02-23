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
  
  def new
    @review_item = ReviewItem.new
    @review_item.addresses.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @review_item = ReviewItem.new(params[:review_item])
    if @review_item.save
      redirect_to @review_item, :notice => "Successfully created review_item."
      else
      render :action => 'new'
    end
  end
  
  def edit
    @review_item = ReviewItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @review_item = ReviewItem.find(params[:id])
    if @review_item.update_attributes(params[:review_item])
      redirect_to @review_item, :notice  => "Successfully updated review_item."
      else
      render :action => 'edit'
    end
  end
  
  def destroy
    @review_item = ReviewItem.find(params[:id])
    @review_item.destroy
    redirect_to review_items_url, :notice => "Successfully deleted review_item."
  end
end
