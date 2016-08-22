class NotificationsController < ApplicationController
  skip_before_filter :require_authentication, only: [:notify]

  def notify
    authorize! :notify, :notifications
    SystemNotifier.javascript_error(params)
    render json: nil, status: :ok
  end
end
