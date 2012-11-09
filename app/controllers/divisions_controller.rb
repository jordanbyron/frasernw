class DivisionsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @divisions = Division.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @division = Division.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @division = Division.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @division = Division.new(params[:division])
    if @division.save
      redirect_to @division, :notice => "Successfully created division."
      else
      render :action => 'new'
    end
  end
  
  def edit
    @division = Division.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      redirect_to @division, :notice  => "Successfully updated division."
      else
      render :action => 'edit'
    end
  end
  
  def destroy
    @division = Division.find(params[:id])
    @division.destroy
    redirect_to divisions_path, :notice => "Successfully deleted division."
  end
end
