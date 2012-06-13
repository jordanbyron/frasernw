class ScItemsController < ApplicationController
  load_and_authorize_resource
  
  #cache_sweeper :sc_item_sweeper, :only => [:create, :update, :destroy]
  
  def index
    @sc_items = ScItem.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @sc_item = ScItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @sc_item = ScItem.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @sc_item = ScItem.new(params[:sc_item])
    if @sc_item.save
      redirect_to @sc_item, :notice => "Successfully created sc_item."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @sc_item = ScItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @sc_item = ScItem.find(params[:id])
    #ScItemSweeper.instance.before_controller_update(@sc_item)
    if @sc_item.update_attributes(params[:sc_item])
      redirect_to @sc_item, :notice  => "Successfully updated sc_item."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @sc_item = ScItem.find(params[:id])
    #ScItemSweeper.instance.before_controller_destroy(@sc_item)
    @sc_item.destroy
    redirect_to sc_items_url, :notice => "Successfully deleted sc_item."
  end
end
