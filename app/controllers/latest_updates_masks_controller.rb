class LatestUpdatesMasksController < ApplicationController
  def create
    @division = Division.find(params[:division_id])

    authorize! :hide_updates, @division

    @mask = LatestUpdatesMask.create(params)

    NewsItem.bust_cache_for(@division)

    redirect_to latest_updates_path(division_id: params[:division_id]),
      notice: "Update to '#{@mask.item_name}' was hidden."
  end
end
