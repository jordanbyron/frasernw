class DivisionsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:shared_sc_items, :update_shared]
  skip_authorization_check :only => [:shared_sc_items, :update_shared]
  before_filter :authorize_division_for_user, :only => [:shared_sc_items, :update_shared]

  def index
    @divisions = Division.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @division = Division.find(params[:id])
    @local_referral_cities = generate_local_referral_cities(@division)
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
      first_division = Division.find(1)
      default_owner = User.super_admin.first
      Specialization.all.each do |s|
        old_so = SpecializationOption.find_by_division_id_and_specialization_id( first_division.id, s.id )
        new_so = SpecializationOption.find_or_create_by_division_id_and_specialization_id( @division.id, s.id )
        new_so.in_progress = old_so.in_progress
        new_so.owner = old_so.owner.super_admin? ? old_so.owner : default_owner
        new_so.content_owner = old_so.content_owner.super_admin? ? old_so.content_owner : default_owner
        new_so.open_to_type = old_so.open_to_type
        new_so.open_to_sc_category_id = old_so.open_to_sc_category_id
        new_so.is_new = old_so.is_new
        new_so.show_specialist_categorization_1 = old_so.show_specialist_categorization_1
        new_so.show_specialist_categorization_2 = old_so.show_specialist_categorization_2
        new_so.show_specialist_categorization_3 = old_so.show_specialist_categorization_3
        new_so.show_specialist_categorization_4 = old_so.show_specialist_categorization_4
        new_so.show_specialist_categorization_5 = old_so.show_specialist_categorization_5
        new_so.save
      end
      redirect_to @division, :notice => "Successfully created division."
    else
      render :action => 'new'
    end
  end

  def edit
    @division = Division.find(params[:id])
    @local_referral_cities = generate_local_referral_cities(@division)
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
      end ## ^^^DevNote: dangerous code if params incorrect
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

  def shared_sc_items
    @division = Division.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update_shared
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      redirect_to shared_content_items_path(@division), :notice  => "Successfully updated shared content items."
    else
      render :action => 'shared_sc_items'
    end
  end

  def destroy
    @division = Division.find(params[:id])
    @division.destroy
    redirect_to divisions_path, :notice => "Successfully deleted division."
  end

  private

  def authorize_division_for_user
    if !(current_user_is_super_admin? || (current_user_divisions.include? Division.find(params[:id])))
      redirect_to root_url, :notice => "You are not allowed to access this page"
    end
  end

  def generate_local_referral_cities(division)
    local_referral_cities = {}
    City.all.each do |city|
      local_referral_cities[city.id] = []
    end
    Specialization.all.each do |specialization|
      cities = division.local_referral_cities_for_specialization(specialization)
      cities.each do |city|
        local_referral_cities[city.id] << specialization.id
      end
    end
    return local_referral_cities
  end
end
