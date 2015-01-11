class NotificationsController < ApplicationController
  load_and_authorize_resource
  def index
    @notifications = PublicActivity::Activity.order("created_at DESC").all
    #@notifications = PublicActivity::Activity.order("created_at DESC").where(owner_id: current_user.division, owner_type: "Admin")
  end

end
