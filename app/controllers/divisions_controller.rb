class DivisionsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:shared_sc_items, :update_shared]
  skip_authorization_check only: [:shared_sc_items, :update_shared]
  before_filter :authorize_division_for_user,
    only: [:shared_sc_items, :update_shared]

  def index
    @divisions = Division.all
  end

  def show
    @division = Division.find(params[:id])
    @local_referral_cities = generate_local_referral_cities(@division)
    @division_referral_cities_by_priority =
      DivisionReferralCity.
        includes(:city).
        where(division_id: @division.id).
        order("priority asc")
    @priority_rankings =
      @division_referral_cities_by_priority.map(&:priority).uniq
  end

  def new
    @division = Division.new
    @local_referral_cities = {}
    City.all.each do |city|
      @local_referral_cities[city.id] = []
    end
    @city_priorities = City.options_for_priority_select(@division)
    @divisional_resource_subscription =
      DivisionalResourceSubscription.
        find_or_create_by(division_id: @division.id)
  end

  def create
    @division = Division.new(params[:division])
    if @division.save
      UpdateDivisionalResourceSubscriptions.exec(@division, params)
      DivisionReferralCity.save_all_for_division(
        @division,
        params[:city_priorities]
      )
      if params[:local_referral_cities].present?
        #add new specializations
        params[:local_referral_cities].each do |city_id, specializations|
          division_referral_city = DivisionReferralCity.find_by(
            division_id: @division.id,
            city_id: city_id
          )
          specializations.each do |specialization_id, checkbox_val|
            DivisionReferralCitySpecialization.find_or_create_by(
              division_referral_city_id: division_referral_city.id,
              specialization_id: specialization_id
            )
          end
        end
      end

      CreateSpecializationOptions.call(division: @division)

      RegenerateDenormalizedDivisions.call(delay: true)

      redirect_to @division, notice: "Successfully created division."
    else
      render action: 'new'
    end
  end

  def edit
    @division = Division.find(params[:id])
    @local_referral_cities = generate_local_referral_cities(@division)
    @city_priorities = City.options_for_priority_select(@division)
    @divisional_resource_subscription =
      DivisionalResourceSubscription.
        find_or_create_by(division_id: @division.id)
  end

  def update
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      UpdateDivisionalResourceSubscriptions.exec(@division, params)
      DivisionReferralCity.save_all_for_division(
        @division,
        params[:city_priorities]
      )
      if params[:local_referral_cities].present?
        @division.division_referral_city_specializations.reject do |drcs|
          params[:local_referral_cities].keys.include?(drcs.city_id.to_s) &&
            params[:local_referral_cities][drcs.city_id.to_s].
              keys.
              include?(drcs.specialization_id.to_s)
        end.each do |drcs|
          DivisionReferralCitySpecialization.destroy(drcs.id)
        end
        params[:local_referral_cities].each do |city_id, specialization_ids|
          division_referral_city = DivisionReferralCity.find_by(
            division_id: @division.id,
            city_id: city_id
          )
          specialization_ids.each do |specialization_id, checkbox_val|
            DivisionReferralCitySpecialization.find_or_create_by(
              division_referral_city_id: division_referral_city.id,
              specialization_id: specialization_id
            )
          end
        end
      else
        @division.division_referral_city_specializations.each do |drcs|
          drcs.destroy
        end
      end
      RegenerateDenormalizedDivisions.call(delay: true)
      @division.city_rankings(force: true)

      redirect_to @division, notice: "Successfully updated division."
    else
      render action: 'edit'
    end
  end

  def shared_sc_items
    @division = Division.find(params[:id])
    @categories = ScCategory.with_items_borrowable_by_division(@division)
  end

  def update_shared
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      redirect_to shared_content_items_path(@division),
        notice: "Successfully updated shared content items."
    else
      render action: 'shared_sc_items'
    end
  end

  def destroy
    @division = Division.find(params[:id])
    @division.destroy
    redirect_to divisions_path, notice: "Successfully deleted division."
  end

  def edit_permissions
    @permission_type = params[:permission_type]
    @division = Division.find(params[:id])
    @dropdown_options = @division.
      admins.
      map{ |admin| [ admin.name, admin.id ] }.
      push([ "Please select", 0 ])

    @permission_type_label = {
      "owner" => "Specialist and Clinic Owner",
      "content_owner" => "Content Owner"
    }[@permission_type]
  end

  def update_permissions
    @user = User.find(params[:admin_id])
    @division = Division.find(params[:id])

    raise unless @division.admins.include?(@user)
    raise unless ["owner", "content_owner"].include?(params[:permission_type])

    Specialization.all.each do |specialization|
      specialization_option = (
        specialization.
          specialization_options.
          where(division_id: @division.id).
          first ||
        specialization.specialization_options.create(division_id: @division.id)
      )

      specialization_option.update_attributes(params[:permission_type] => @user)
    end

    redirect_to specializations_path, notice: "Update Successful"
  end

  private

  def authorize_division_for_user
    if (
      !current_user.as_super_admin? &&
        !current_user.as_divisions.include?(Division.find(params[:id]))
    )
      redirect_to root_url, notice: "You are not allowed to access this page"
    end
  end

  def generate_local_referral_cities(division)
    City.all.inject({}) do |memo, city|
      memo.merge(
        city.id => division.specializations_referred_to(city).map(&:id)
      )
    end
  end
end
