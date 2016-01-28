class LatestUpdatesMasksController < ApplicationController
  def create
    @division = Division.find(params[:division_id])

    authorize! :hide_updates, @division

    @mask = LatestUpdatesMask.create(params)

    NewsItem.bust_cache_for(@division)

    render nothing: true, status: 200
  end
end
