class NewsItemsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @news_items = NewsItem.paginate(:page => params[:page], :per_page => 30)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @news_item = NewsItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @news_item = NewsItem.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      redirect_to @news_item, :notice => "Successfully created news item."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @news_item = NewsItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      redirect_to @news_item, :notice  => "Successfully updated news item."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to news_items_path, :notice => "Successfully deleted news item."
  end
end
