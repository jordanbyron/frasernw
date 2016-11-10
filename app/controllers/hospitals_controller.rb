class HospitalsController < ApplicationController
  skip_before_filter :require_authentication, only: :refresh_cache
  load_and_authorize_resource except: :refresh_cache
  before_filter :check_token, only: :refresh_cache
  skip_authorization_check only: :refresh_cache

  def index
    @hospitals = Hospital.all
  end

  def show
    @hospital = Hospital.find(params[:id])
  end

  def new
    @hospital = Hospital.new
    @hospital.build_location
    @hospital.location.build_address
  end

  def create
    @hospital = Hospital.new(params[:hospital])
    if @hospital.save
      redirect_to @hospital, notice: "Successfully created #{@hospital.name}."
    else
      render action: 'new'
    end
  end

  def edit
    @hospital = Hospital.find(params[:id])
    if @hospital.location.blank?
      @hospital.build_location
      @hospital.location.build_address
    elsif @hospital.location.address.blank?
      @hospital.build_address
    end
  end

  def update
    @hospital = Hospital.find(params[:id])
    ExpireFragment.call hospital_path(@hospital)
    if @hospital.update_attributes(params[:hospital])
      redirect_to @hospital, notice: "Successfully updated #{@hospital.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    @hospital = Hospital.find(params[:id])
    ExpireFragment.call hospital_path(@hospital)
    name = @hospital.name
    @hospital.destroy
    redirect_to hospitals_url, notice: "Successfully deleted #{@hospital.name}."
  end

  def check_token
    token_required( Hospital, params[:token], params[:id] )
  end

  def refresh_cache
    @hospital = Hospital.find(params[:id])
    @specialists_with_offices_in =
      @hospital.offices_in.map{ |o| o.specialists }.flatten.uniq
    render :show
  end
end
