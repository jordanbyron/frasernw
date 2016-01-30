class FrontController < ApplicationController
  include ApplicationHelper

  def index
    authorize! :index, :front

    if current_user_is_admin?
      @as_division = begin
        if params[:division_id].present?
          Division.find(params[:division_id])
        else
          current_user_divisions.first
        end
      end
      @can_edit_division = current_user_is_super_admin? || current_user_divisions.include?(@as_division)

      @as_divisions = [ @as_division ]
      @specializations = Specialization.all
      @more_updates_url = latest_updates_path(division_id: @as_division.id)
    else
      @as_divisions = current_user_divisions
      @specializations = Specialization.not_in_progress_for_divisions(current_user_divisions).uniq
      @more_updates_url = latest_updates_path
    end

    @current_newsletter = Newsletter.current
    @news_items = NewsItem.breaking_in_divisions(@as_divisions)
    @divisional_updates = NewsItem.divisional_in_divisions(@as_divisions)
    @attachment_updates = NewsItem.attachment_in_divisions(@as_divisions)
    @shared_care_updates = NewsItem.shared_care_in_divisions(@as_divisions)
  end
end
