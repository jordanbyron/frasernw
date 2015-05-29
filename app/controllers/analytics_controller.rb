class AnalyticsController < ApplicationController
  def show
    authorize! :show, :analytics
  end
end
