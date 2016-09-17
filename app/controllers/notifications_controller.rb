class NotificationsController < ApplicationController
  skip_before_filter :require_authentication, only: [:notify]

  def notify
    authorize! :notify, :notifications

    if ENV["APP_NAME"] != "pathwaysbclocal"
      SystemNotifier.javascript_error(params += user_info)
    end

    render json: nil, status: :ok
  end

  private

  def user_info
    [user_id: current_user.id, user_mask: current_user.user_mask.role]
  end

end
