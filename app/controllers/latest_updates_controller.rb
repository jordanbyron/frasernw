class LatestUpdatesController < ApplicationController
  skip_authorization_check

  def index
    authorize! :index, :latest_updates
  end
end
