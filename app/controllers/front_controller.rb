class FrontController < ApplicationController
  include ApplicationHelper

  def index
    authorize! :index, :front

    if current_user.as_admin_or_super?
      @as_division = begin
        if params[:division_id].present?
          Division.find(params[:division_id])
        else
          current_user.as_divisions.first
        end
      end
      @can_edit_division = current_user.as_super_admin? || current_user.as_divisions.include?(@as_division)

      @as_divisions = [ @as_division ]
      @specializations = Specialization.all
      @more_updates_url = latest_updates_path(division_id: @as_division.id)
    else
      @as_divisions = current_user.as_divisions
      @specializations =
        Specialization.for_users_in(*current_user.as_divisions)
      @more_updates_url = latest_updates_path
    end

    @current_newsletter = Newsletter.current
    @news_items = NewsItem.breaking_in_divisions(@as_divisions).current
    @divisional_updates = NewsItem.divisional_in_divisions(@as_divisions).current
    @attachment_updates = NewsItem.attachment_in_divisions(@as_divisions).current
    @shared_care_updates = NewsItem.shared_care_in_divisions(@as_divisions).current
  end
end
