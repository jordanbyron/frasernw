class NotificationsController < ApplicationController
  load_and_authorize_resource
  def index
    @notifications = current_user.activities
  end

  def master
    redirect_to notifications_path unless current_user.as_super_admin?
    @notifications = PublicActivity::Activity.order("created_at DESC").all
  end

end
