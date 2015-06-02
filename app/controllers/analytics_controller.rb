class AnalyticsController < ApplicationController
  include ApplicationHelper

  def show
    authorize! :show, :analytics
    @chart_config = Analytics::ChartBuilder.new(params).exec
  end
end
