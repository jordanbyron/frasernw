class LatestUpdatesController < ApplicationController
  skip_authorization_check

  def index
    @divisions = begin
      if params[:division_id].present?
        [ Division.find(params[:division_id]) ]
      elsif current_user.as_admin_or_super?
        [ current_user.as_divisions.first ]
      else
        current_user.as_divisions
      end
    end

    @init_data = {
      ui: {
        persistentConfig: {
          divisionIds: @divisions.map(&:id),
          canHide: ((current_user.as_admin? &&
            current_user.as_divisions.include?(@divisions.first)) ||
            current_user.as_super_admin?)
        },
        latestUpdates: LatestUpdates.for(:index, @divisions)
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

    LatestUpdates.recache_for_groups(User.division_groups_for(@division))

    render nothing: true, status: 200
  end
end
