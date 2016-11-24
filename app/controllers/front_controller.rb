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
    else
      @as_divisions = current_user.as_divisions
      @specializations =
        Specialization.for_users_in(*current_user.as_divisions)
    end

    @current_newsletter = Newsletter.current
    @news_items = NewsItem.breaking_in_divisions(@as_divisions)
    @divisional_updates = NewsItem.divisional_in_divisions(@as_divisions)
    @attachment_updates = NewsItem.attachment_in_divisions(@as_divisions)
    @shared_care_updates = NewsItem.shared_care_in_divisions(@as_divisions)
  end
end
