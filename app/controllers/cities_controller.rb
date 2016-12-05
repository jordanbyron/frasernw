class CitiesController < ApplicationController
  load_and_authorize_resource

  def index
    @cities = City.all
  end

  def show
    @city = City.find(params[:id])
  end

  def new
    @city = City.new
  end

  def create
    @city = City.new(params[:city])
    if @city.save
      Division.all.each do |division|
        DivisionReferralCity.create(
          division_id: division.id,
          city_id: @city.id,
          priority: division.division_referral_cities.map(&:priority).max
        )
      end

      redirect_to @city, notice: "Successfully created city."
      else
      render action: 'new'
    end
  end

  def edit
    @city = City.find(params[:id])
  end

  def update
    @city = City.find(params[:id])
    if @city.update_attributes(params[:city])
      redirect_to @city, notice: "Successfully updated city."
      else
      render action: 'edit'
    end
  end

  def destroy
    @city = City.find(params[:id])
    @city.destroy
    redirect_to cities_path, notice: "Successfully deleted city."
  end
end
