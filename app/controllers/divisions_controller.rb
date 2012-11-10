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
    @local_referral_cities = {}
    @division.specializations.each do |s|
      @local_referral_cities[s.id] = @division.local_referral_cities_for_specialization(s).map{ |c| c.id }
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      @division.division_specializations.each do |ds|
        #remove existing specializations that no longer exist
        DivisionSpecialization.destroy(ds.id) if (params[:specialization].blank? || !(params[:specialization].include? ds.specialization_id))
      end
      if params[:specialization].present?
        #add new specializations
        params[:specialization].each do |specialization_id, set|
          DivisionSpecialization.find_or_create_by_division_id_and_specialization_id( @division.id, specialization_id )
        end
      end
      @division.division_specialization_cities.each do |dsc|
        #remove existing cities that no longer exist
        DivisionSpecializationCity.destroy(dcs.id) if (!(params[:local_referral_city].include? dcs.specialization_id) || !(params[:local_referral_city][dcs.specialization_id].include? dcs.city_id))
      end
      if params[:local_referral_city].present?
        #add new cities
        params[:local_referral_city].each do |specialization_id, cities|
          division_specialization = DivisionSpecialization.find_by_division_id_and_specialization_id( @division.id, specialization_id )
          if division_specialization.present?
            #parent specialization was checked off
            cities.each do |city_id, set|
              DivisionSpecializationCity.find_or_create_by_division_specialization_id_and_city_id( division_specialization.id, city_id )
            end
          end
        end
      end
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
