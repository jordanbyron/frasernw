class SpecializationsController < ApplicationController
  load_and_authorize_resource

  def index
    @specializations = Specialization.all
  end

  def show
    @layout_heartbeat_loader = false
    @specialization = Specialization.find(params[:id])
  end

  def new
    @specialization = Specialization.new
  end

  def create
    @specialization = Specialization.new(params[:specialization])
    if @specialization.save
      Division.all.each do |division|
        puts division.name
        so = SpecializationOption.find_or_create_by(
          specialization_id: @specialization.id,
          division_id: division.id
        )
        so.owner =
          User.find_by_id(params[:owner]["#{division.id}"]) ||
          division.admins.first
        so.content_owner =
          User.find_by_id(params[:content_owner]["#{division.id}"]) ||
          division.admins.first
        so.hide_from_division_users =
          params[:hide_from_division_users].present? &&
          params[:hide_from_division_users]["#{division.id}"].present?
        so.is_new =
          params[:is_new].present? &&
          params[:is_new]["#{division.id}"].present?
        so.open_to_type = params[:open_to_type]["#{division.id}"]
        so.open_to_sc_category = (
            params[:open_to_type]["#{division.id}"] == SpecializationOption::OPEN_TO_SC_CATEGORY.to_s
          ) ? ScCategory.find(params[:open_to_sc_category]["#{division.id}"]) : nil
        so.save

        division.refer_to_encompassed_cities!(@specialization)
      end
      Denormalized.regenerate(:specializations)
      redirect_to @specialization, notice: "Successfully created specialty."
    else
      render action: 'new'
    end
  end

  def edit
    @specialization = Specialization.find(params[:id])
    Division.all.each { |division| SpecializationOption.find_or_create_by(
      specialization_id: params[:id],
      division_id: division.id
    ) }
  end

  def update
    @specialization = Specialization.find(params[:id])
    ExpireFragment.call specialization_path(@specialization)
    if current_user.as_super_admin?
      divisions = Division.all
    else
      divisions = current_user.as_divisions
    end

    if @specialization.update_attributes(params[:specialization])
      divisions.each do |division|
        puts division.name
        so = SpecializationOption.find_by(
          specialization_id: @specialization.id,
          division_id: division.id
        )
        so.owner = User.find_by_id(params[:owner]["#{division.id}"])
        so.content_owner = User.find_by_id(params[:content_owner]["#{division.id}"])
        so.hide_from_division_users =
          params[:hide_from_division_users].present? &&
          params[:hide_from_division_users]["#{division.id}"].present?
        so.is_new =
          params[:is_new].present? && params[:is_new]["#{division.id}"].present?
        so.open_to_type = params[:open_to_type]["#{division.id}"]
        so.open_to_sc_category = (
            params[:open_to_type]["#{division.id}"] == SpecializationOption::OPEN_TO_SC_CATEGORY.to_s
          ) ? ScCategory.find(params[:open_to_sc_category]["#{division.id}"]) : nil

        so.save
      end
      Denormalized.regenerate(:specializations)
      redirect_to @specialization, notice: "Successfully updated specialty."
    else
      render action: 'edit'
    end
  end

  def destroy
    @specialization = Specialization.find(params[:id])
    ExpireFragment.call specialization_path(@specialization)
    @specialization.destroy
    redirect_to specializations_url, notice: "Successfully deleted specialty."
  end

  def check_token
    token_required( Specialization, params[:token], params[:id] )
  end
end
