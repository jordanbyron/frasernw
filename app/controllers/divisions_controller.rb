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
    @local_referral_cities = {}
    City.all.each do |city|
      @local_referral_cities[city.id] = []
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @division = Division.new(params[:division])
    if @division.save
      if params[:city].present?
        #add new cities
        params[:city].each do |city_id, set|
          DivisionReferralCity.find_or_create_by_division_id_and_city_id( @division.id, city_id )
        end
      end
      if params[:local_referral_cities].present?
        #add new specializations
        params[:local_referral_cities].each do |city_id, specializations|
          division_referral_city = DivisionReferralCity.find_by_division_id_and_city_id( @division.id, city_id )
          if division_referral_city.present?
            #parent city was checked off
            specializations.each do |specializations_id, set|
              DivisionReferralCitySpecialization.find_or_create_by_division_referral_city_id_and_specialization_id( division_referral_city.id, specializations_id )
            end
          end
        end
      end
      redirect_to @division, :notice => "Successfully created division."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @division = Division.find(params[:id])
    @local_referral_cities = {}
    City.all.each do |city|
      @local_referral_cities[city.id] = []
    end
    Specialization.all.each do |specialization|
      cities = @division.local_referral_cities_for_specialization(specialization)
      cities.each do |city|
        @local_referral_cities[city.id] << specialization.id
      end
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      @division.division_referral_cities.each do |uc|
        #remove existing cities that no longer exist
        DivisionReferralCity.destroy(uc.id) if (params[:city].blank? || !(params[:city].include? uc.city_id))
      end
      if params[:city].present?
        #add new cities
        params[:city].each do |city_id, set|
          DivisionReferralCity.find_or_create_by_division_id_and_city_id( @division.id, city_id )
        end
      end
      @division.division_referral_city_specializations.each do |ucs|
        #remove existing specializations that no longer exist
        DivisionReferralCitySpecialization.destroy(ucs.id) if (!(params[:local_referral_cities].include? ucs.city_id) || !(params[:local_referral_cities][usc.city_id].include? usc.specialization_id))
      end
      if params[:local_referral_cities].present?
        #add new specializations
        params[:local_referral_cities].each do |city_id, specializations|
          division_referral_city = DivisionReferralCity.find_by_division_id_and_city_id( @division.id, city_id )
          if division_referral_city.present?
            #parent city was checked off
            specializations.each do |specializations_id, set|
              DivisionReferralCitySpecialization.find_or_create_by_division_referral_city_id_and_specialization_id( division_referral_city.id, specializations_id )
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
