class NotificationsController < ApplicationController
  skip_before_filter :require_authentication, only: [:notify]

  def notify
    authorize! :notify, :notifications

    if ENV["APP_NAME"] != "pathwaysbcdevelopment"
      SystemNotifier.javascript_error(params)
    end

    render json: nil, status: :ok
  end
end
