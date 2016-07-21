class NotificationsController < ApplicationController
  skip_authorization_check
  skip_before_filter :verify_authenticity_token, only: :notify

  def notify
    SystemNotifier.javascript_error(params)
    render json: nil, status: :ok
  end
end
