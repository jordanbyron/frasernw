class ReportsController < ApplicationController
  def index
    authorize! :index, :reports
  end

  def page_views
    authorize! :view_report, :page_views

    @page_title = "User Page Views"
    @data_path = "/api/v1/reports/page_views"
    @annotation = <<-STR
      This report shows the number of times users have viewed pages on Pathways
       for each week in the given month range. The divisional series show the
      number of page views that are made by each division's users. All series
      exclude page views by admins and users who are not logged in, as well as
      page views on external sites (i.e. external resource links and uploaded
      items). Only complete weeks (Mon-Sun) are shown. Click on division names
      in the legend to the right to select which divisions to display.
    STR

    render :analytics_chart
  end

  def sessions
    authorize! :view_report, :sessions

    @page_title = "User Sessions"
    @data_path = "/api/v1/reports/sessions"
    @annotation = <<-STR
      This report shows the number of sessions that have been recorded on
      Pathways for each week in the given month range. A session is a group of
      page views by the same user which are no more than 30 minutes apart. The
      divisional series show the number of sessions attributable to each
      division's users. All series exclude sessions attributable to admins and
      users who are not logged in. Only complete weeks (Mon-Sun) are shown.
      Click on division names in the legend to the right to select which
      divisions to display.
    STR

    render :analytics_chart
  end

  def user_ids
    authorize! :view_report, :sessions

    @page_title = "User IDs"
    @data_path = "/api/v1/reports/user_ids"
    @annotation = <<-STR
      This report shows the number of user IDs (email and password combinations)
      that have logged into Pathways for each week in the given month range.
      The divisional series show the number of logged in user IDs linked to
      each division. All series exclude admin user IDs. Only complete weeks
      (Mon-Sun) are shown. Click on division names in the legend to the right
      to select which divisions to display.
    STR

    render :analytics_chart
  end

  def page_views_by_user
    authorize! :view_report, :page_views_by_user

    @init_data = {
      app: {
        currentUser: Denormalized::CurrentUser.call(
          current_user: current_user
        ),
      }
    }
  end

  def profiles_by_specialty
    authorize! :view_report, :profiles_by_specialty
  end

  def entity_page_views
    @layout_heartbeat_loader = false

    authorize! :view_report, :entity_page_views
  end

  def specialist_contact_history
    set_divisions_from_params!
    authorize! :view_report, :specialist_contact_history

    @specialists = Specialist.in_divisions(@divisions)
    Specialist.preload_associations(@specialists, :specializations)
    Specialist.preload_associations(@specialists, :controlling_users)
    Specialist.preload_associations(@specialists, :review_items)

    @specialization_specialists =
      Specialization.all.inject({}) do |memo, specialization|
        specialization_entries = @specialists.select do |specialist|
          specialist.specializations.to_a.include?(specialization)
        end.map do |specialist|
          last_review_item = specialist.review_items.sort_by(&:created_at).last
          active_controlling_users = specialist.
            controlling_users.
            reject{ |user| user.pending? || !user.active? }

          {
            id: specialist.id,
            name: specialist.name,
            user_email: active_controlling_users.
              map(&:email).
              map(&:split).
              flatten.
              select{ |email| email.include?('@') },
            moa_email: specialist.
              contact_email.
              split.
              flatten.
              select{ |email| email.include?('@') },
            updated_at: specialist.updated_at,
            reviewed_at: (
              last_review_item.present? ? last_review_item.updated_at : nil
            ),
            linked_active_account_count: active_controlling_users.count,
            linked_pending_account_count:
              specialist.controlling_users.select(&:pending?).count
          }
        end

      memo.merge(specialization.name => specialization_entries)
    end
    render :contact_history
  end

  def specialist_wait_times
    set_divisions_from_params!
    authorize! :view_report, :specialist_wait_times
    @entity = "specialists"
    render :wait_times
  end

  def clinic_wait_times
    set_divisions_from_params!
    authorize! :view_report, :clinic_wait_times
    @entity = "clinics"
    render :wait_times
  end

  def entity_statistics
    set_divisions_from_params!
    authorize! :view_report, :entity_statistics
    render :stats
  end

  def archived_feedback_items
    authorize! :view_report, :archived_feedback_items

    scope = FeedbackItem.
      archived.
      order('id desc')

    if params[:division_id].present?
      @division = Division.find(params[:division_id])
      scope = scope.where(
        "(?) = ANY(archiving_division_ids)",
        params[:division_id]
      )
    end

    @feedback_item_types = {}

    [
      :specialist,
      :clinic,
      :content,
      :contact_us
    ].each do |type|
      @feedback_item_types[type] = scope.
        send(type).
        paginate(page: params[:page], per_page: 10)
    end
  end

  def change_requests
    authorize! :view_report, :change_requests

    redirect_to change_requests_path
  end

  def csv_usage
    authorize! :view_report, :csv_usage

    redirect_to new_csv_usage_report_path
  end

  private

  def set_divisions_from_params!
    @divisions =
      if params[:division_id].present?
        [Division.find(params[:division_id])]
      else
        Division.all
      end
    @report_scope =
      if @divisions.length > 1
        "all divisions"
      else
        @divisions.first.name
      end
  end
end
