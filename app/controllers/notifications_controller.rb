class NotificationsController < ApplicationController
  skip_before_filter :require_authentication, only: [:notify]

  def notify
    authorize! :notify, :notifications

    if ENV["APP_NAME"] != "pathwaysbclocal"
      SystemNotifier.javascript_error(params.merge(user_info))
    end
    render json: nil, status: :ok
  end

  private

  def user_info
    {
      userId: current_user.id,
      userMask: current_user.role,
      userName: current_user.name
    }
  end

end
