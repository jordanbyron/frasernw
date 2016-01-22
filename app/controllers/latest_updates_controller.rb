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

    authorize! :index, :latest_updates
  end
end
