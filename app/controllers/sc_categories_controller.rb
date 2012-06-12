class ScCategoriesController < ApplicationController
  load_and_authorize_resource
  
  #cache_sweeper :sc_category_sweeper, :only => [:create, :update, :destroy]
  
  def index
    @sc_categories = ScCategory.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @sc_category = ScCategory.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @sc_category = ScCategory.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @sc_category = ScCategory.new(params[:sc_category])
    if @sc_category.save
      redirect_to @sc_category, :notice => "Successfully created sc_category."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @sc_category = ScCategory.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @sc_category = ScCategory.find(params[:id])
    #ScCategorySweeper.instance.before_controller_update(@sc_category)
    if @sc_category.update_attributes(params[:sc_category])
      redirect_to @sc_category, :notice  => "Successfully updated sc_category."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @sc_category = ScCategory.find(params[:id])
    #ScCategorySweeper.instance.before_controller_destroy(@sc_category)
    @sc_category.destroy
    redirect_to sc_categories_url, :notice => "Successfully deleted sc_category."
  end
end
