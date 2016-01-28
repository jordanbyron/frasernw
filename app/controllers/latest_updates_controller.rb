class LatestUpdatesController < ApplicationController
  skip_authorization_check

  def index
    @divisions = begin
      if params[:division_id].present?
        [ Division.find(params[:division_id]) ]
      elsif current_user_is_admin?
        [ current_user_divisions.first ]
      else
        current_user_divisions
      end
    end

    @init_data = {
      app: {
        divisions: Serialized.fetch(:divisions)
      },
      ui: {
        divisionIds: @divisions.map(&:id),
        canHide: current_user_is_admin? && current_user_divisions.include?(@divisions.first),
        latestUpdates: LatestUpdates.for(:index, @divisions),
        hasBeenInitialized: false
      }
    }

    authorize! :index, :latest_updates
  end

  def toggle_visibility
    @division = Division.find(params[:update][:division_id])

    authorize! :hide_updates, @division

    @mask = LatestUpdatesMask.where(params[:update].except(:hide)).first

    if @mask.present? && params[:update][:hide] == "false"
      @mask.destroy
    elsif params[:update][:hide] == "true"
      LatestUpdatesMask.create(params[:update].except(:hide))
    end

    User.division_groups_for(@division).each do |group|
      LatestUpdates.recache_for(group, force_automatic: false)
    end

    render nothing: true, status: 200
  end
end
