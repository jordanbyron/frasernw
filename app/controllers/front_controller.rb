class FrontController < ApplicationController
  include ApplicationHelper

  def index
    authorize! :index, :front

    if current_user.as_admin_or_super?
      @as_division = begin
        if params[:division_id].present?
          Division.find(params[:division_id])
        elsif current_user.as_divisions.any?
          current_user.as_divisions.first
        else
          Division.find(1)
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

    @news_items = NewsItem::TYPE_HASH.
      keys.
      except(NewsItem::TYPE_SPECIALIST_CLINIC_UPDATE).
      inject({}) do |memo, key|
        memo.merge(key => NewsItem.type_in_divisions(key, @as_divisions))
      end
  end
end
