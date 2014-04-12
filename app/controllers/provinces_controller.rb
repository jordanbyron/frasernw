class ProvincesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @provinces = Province.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @province = Province.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @province = Province.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @province = Province.new(params[:province])
    if @province.save
      redirect_to @province, :notice => "Successfully created province."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @province = Province.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @province = Province.find(params[:id])
    if @province.update_attributes(params[:province])
      redirect_to @province, :notice  => "Successfully updated province."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @province = Province.find(params[:id])
    @province.destroy
    redirect_to provinces_url, :notice => "Successfully deleted province."
  end
end
