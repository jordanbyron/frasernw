class OfficesController < ApplicationController
  load_and_authorize_resource
  
  def index
    if params[:city_id].present?
      @city = City.find(params[:city_id])
      @offices = @city.direct_offices.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}
    else
      @offices = Office.all.reject{ |o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @office = Office.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @office = Office.new
    @office.build_location
    @office.location.build_address
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @office = Office.new(params[:office])
    if @office.save
      redirect_to @office, :notice => "Successfully created office."
      else
      render :action => 'new'
    end
  end
  
  def edit
    @office = Office.find(params[:id])
    @office.build_location if @office.location.blank?
    @office.location.build_address if @office.location.address.blank?
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @office = Office.find(params[:id])
    if @office.update_attributes(params[:office])
      redirect_to @office, :notice  => "Successfully updated office."
      else
      render :action => 'edit'
    end
  end
  
  def destroy
    @office = Office.find(params[:id])
    @office.destroy
    redirect_to offices_url, :notice => "Successfully deleted office."
  end
end
