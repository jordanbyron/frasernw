class AnalyticsController < ApplicationController
  include ApplicationHelper

  def show
    authorize! :show, :analytics
  end
end
