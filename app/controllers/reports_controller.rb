class ReportsController < ApplicationController
  def index
    authorize! :index, :reports
  end

  def page_views
    authorize! :view_report, :page_views

    @options_for_select = AnalyticsChartMonths.exec
    @page_title = "User Page Views"
    @data_path = "/api/v1/reports/page_views"
    @annotation = <<-STR
      This report shows the number of times users have viewed pages on Pathways for each week in the given month range.
      The divisional series show the number of page views that are made by each division's users.
      All series exclude page views by admins and users who are not logged in,
      as well as page views on external sites (i.e. external resource links and uploaded items).
      Only complete weeks (Mon-Sun) are shown.
    STR

    render :analytics_chart
  end

  def sessions
    authorize! :view_report, :sessions

    @options_for_select = AnalyticsChartMonths.exec
    @page_title = "User Sessions"
    @data_path = "/api/v1/reports/sessions"
    @annotation = <<-STR
      This report shows the number of sessions that have been recorded on Pathways for each week in the given month range.
      A session is a group of page views by the same user which are no more than 30 minutes apart.
      The divisional series show the number of sessions attributable to each division's users.
      All series exclude sessions attributable to admins and users who are not logged in.
      Only complete weeks (Mon-Sun) are shown.
    STR

    render :analytics_chart
  end

  def page_views_by_user
    authorize! :view_report, :page_views_by_user

    @init_data = {
      app: {
        currentUser: FilterTableAppState::CurrentUser.call(
          current_user: current_user
        ),
      }
    }
  end

  def user_ids
    authorize! :view_report, :sessions

    @options_for_select = AnalyticsChartMonths.exec
    @page_title = "User IDs"
    @data_path = "/api/v1/reports/user_ids"
    @annotation = <<-STR
      This report shows the number of user IDs (email and password combinations)
      that have logged into Pathways for each week in the given month range.
      The divisional series show the number of logged in user IDs linked to each division.
      All series exclude admin user IDs.
      Only complete weeks (Mon-Sun) are shown.
    STR

    render :analytics_chart
  end

  def referents_by_specialty
    authorize! :view_report, :referents_by_specialty
  end

  def entity_page_views
    @layout_heartbeat_loader = false

    authorize! :view_report, :entity_page_views
  end

  def specialist_contact_history
    set_divisions_from_params!
    authorize! :view_report, :specialist_contact_history
    @specialist_email_table = {}
    Specialization.all.each do |s|
      specialization = []
      specialists = s.specialists.in_divisions(@divisions)
      specialists.sort_by do |sp|
        sp.locations.first.present? ? sp.locations.first.short_address : ""
      end.each do |sp|
        next if !sp.responded? || sp.not_available?
        active_controlling_users =
          sp.controlling_users.reject{ |u| u.pending? || !u.active? }
        entry = {}
        entry[:id] = sp.id
        entry[:name] = sp.name
        entry[:user_email] =
          active_controlling_users.
            map{ |u| u.email }.
            map{ |e| e.split }.
            flatten.
            reject{ |e| !(e.include? '@') }
        entry[:moa_email] =
          sp.contact_email.split.flatten.reject{ |e| !(e.include? '@') }
        entry[:token] = sp.token
        entry[:updated_at] = sp.updated_at
        review_item = sp.review_items.sort_by{ |x| x.id }.last
        entry[:reviewed_at] =
          review_item.present? ? review_item.updated_at : nil
        entry[:linked_active_account_count] = active_controlling_users.count
        entry[:linked_pending_account_count] =
          sp.controlling_users.reject{ |u| !u.pending? }.count
        specialization << entry
      end
      @specialist_email_table[s.id] = specialization
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
