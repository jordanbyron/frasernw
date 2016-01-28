class LatestUpdatesController < ApplicationController
  skip_authorization_check

  def index
    @divisions = begin
      if params[:division_id].present?
        [ Division.find(params[:division_id]) ]
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
end
