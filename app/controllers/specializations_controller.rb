class SpecializationsController < ApplicationController
  load_and_authorize_resource

  def index
    @specializations = Specialization.all
    render layout: 'ajax' if request.headers['X-PJAX']
  end

  def show
    @layout_heartbeat_loader = false
    @specialization = Specialization.find(params[:id])
    @init_data = {
      app: FilterTableAppState.exec(current_user: current_user),
      ui: {
        pageType: "specialization",
        specializationId: @specialization.id,
        hasBeenInitialized: false
      }
    }
  end

  def new
    @specialization = Specialization.new
    render layout: 'ajax' if request.headers['X-PJAX']
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
        so.in_progress =
          params[:in_progress].present? &&
          params[:in_progress]["#{division.id}"].present?
        so.is_new =
          params[:is_new].present? &&
          params[:is_new]["#{division.id}"].present?
        so.open_to_type = params[:open_to_type]["#{division.id}"]
        so.open_to_sc_category = (
            params[:open_to_type]["#{division.id}"] == SpecializationOption::OPEN_TO_SC_CATEGORY.to_s
          ) ? ScCategory.find(params[:open_to_sc_category_id]["#{division.id}"]) : nil
        so.show_specialist_categorization_1 =
          params[:show_specialist_categorization_1].present? &&
          params[:show_specialist_categorization_1]["#{division.id}"].present?
        so.show_specialist_categorization_2 =
          params[:show_specialist_categorization_2].present? &&
          params[:show_specialist_categorization_2]["#{division.id}"].present?
        so.show_specialist_categorization_3 =
          params[:show_specialist_categorization_3].present? &&
          params[:show_specialist_categorization_3]["#{division.id}"].present?
        so.show_specialist_categorization_4 =
          params[:show_specialist_categorization_4].present? &&
          params[:show_specialist_categorization_4]["#{division.id}"].present?
        so.show_specialist_categorization_5 =
          params[:show_specialist_categorization_5].present? &&
          params[:show_specialist_categorization_5]["#{division.id}"].present?
        so.save

        division.refer_to_encompassed_cities(@specialization)
      end
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
    render layout: 'ajax' if request.headers['X-PJAX']
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
        so.in_progress =
          params[:in_progress].present? &&
          params[:in_progress]["#{division.id}"].present?
        so.is_new =
          params[:is_new].present? && params[:is_new]["#{division.id}"].present?
        so.open_to_type = params[:open_to_type]["#{division.id}"]
        so.open_to_sc_category = (
            params[:open_to_type]["#{division.id}"] == SpecializationOption::OPEN_TO_SC_CATEGORY.to_s
          ) ? ScCategory.find(params[:open_to_sc_category]["#{division.id}"]) : nil
        so.show_specialist_categorization_1 =
          params[:show_specialist_categorization_1].present? &&
          params[:show_specialist_categorization_1]["#{division.id}"].present?
        so.show_specialist_categorization_2 =
          params[:show_specialist_categorization_2].present? &&
          params[:show_specialist_categorization_2]["#{division.id}"].present?
        so.show_specialist_categorization_3 =
          params[:show_specialist_categorization_3].present? &&
          params[:show_specialist_categorization_3]["#{division.id}"].present?
        so.show_specialist_categorization_4 =
          params[:show_specialist_categorization_4].present? &&
          params[:show_specialist_categorization_4]["#{division.id}"].present?
        so.show_specialist_categorization_5 =
          params[:show_specialist_categorization_5].present? &&
          params[:show_specialist_categorization_5]["#{division.id}"].present?
        so.save
      end
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
