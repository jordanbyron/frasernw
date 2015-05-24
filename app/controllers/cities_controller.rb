class CitiesController < ApplicationController
  load_and_authorize_resource

  def index
    @citys = City.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @city = City.cached_find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @city = City.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @city = City.new(params[:city])
    if @city.save
      redirect_to @city, :notice => "Successfully created city."
      else
      render :action => 'new'
    end
  end

  def edit
    @city = City.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @city = City.find(params[:id])
    if @city.update_attributes(params[:city])
      redirect_to @city, :notice  => "Successfully updated city."
      else
      render :action => 'edit'
    end
  end

  def destroy
    @city = City.find(params[:id])
    @city.destroy
    redirect_to cities_path, :notice => "Successfully deleted city."
  end
end
