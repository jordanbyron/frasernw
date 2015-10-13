class ReportsController < ApplicationController
  load_and_authorize_resource except: [:page_views, :sessions, :referents_by_specialty]

  def index
    @reports = Report.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def page_views
    authorize! :view_report, :page_views

    @options_for_select = AnalyticsChartMonths.exec
    @page_title = "User Page Views"
    @data_path = "/api/v1/reports/page_views"

    render :analytics_chart
  end

  def sessions
    authorize! :view_report, :sessions

    @options_for_select = AnalyticsChartMonths.exec
    @page_title = "User Sessions"
    @data_path = "/api/v1/reports/sessions"

    render :analytics_chart
  end

  def referents_by_specialty
    @init_data = {
      app: {
        specializations: Serialized.fetch(:specializations)
      }
    }

    authorize! :view_report, :referents_by_specialty
  end

  def show
    @report = Report.find(params[:id])

    case @report.type_mask
    when Report::ReportType::SPECIALIST_CONTACT_HISTORY

      @specialist_email_table = {}
      @divisions = @report.divisional? ? [@report.division] : Division.all
      Specialization.all.each do |s|
        next if s.fully_in_progress_for_divisions(@divisions)
        specialization = []
        specialists = @report.divisional? ? s.specialists.in_divisions(@divisions) : s.specialists
        specialists.sort_by{ |sp| sp.locations.first.present? ? sp.locations.first.short_address : ""}.each do |sp|
          next if !sp.responded? || sp.not_available?
          active_controlling_users = sp.controlling_users.reject{ |u| u.pending? || !u.active? }
          entry = {}
          entry[:id] = sp.id
          entry[:name] = sp.name
          entry[:user_email] = active_controlling_users.map{ |u| u.email }.map{ |e| e.split }.flatten.reject{ |e| !(e.include? '@') }
          entry[:moa_email] = sp.contact_email.split.flatten.reject{ |e| !(e.include? '@') }
          entry[:token] = sp.token
          entry[:updated_at] = sp.updated_at
          review_item = sp.review_items.sort_by{ |x| x.id }.last
          entry[:reviewed_at] = review_item.present? ? review_item.updated_at : nil
          entry[:linked_active_account_count] = active_controlling_users.count
          entry[:linked_pending_account_count] = sp.controlling_users.reject{ |u| !u.pending? }.count
          specialization << entry
        end
        @specialist_email_table[s.id] = specialization
      end
    when Report::ReportType::ENTITY_STATS
      @divisional = @report.divisional?
      @divisions = @report.divisional? ? [@report.division] : Division.all
      render :stats
    when Report::ReportType::SPECIALIST_WAIT_TIMES
      @divisional = @report.divisional?
      @divisions = @report.divisional? ? [@report.division] : Division.all
      @entity = "specialists"
      render :wait_times
    when Report::ReportType::CLINIC_WAIT_TIMES
      @divisional = @report.divisional?
      @divisions = @report.divisional? ? [@report.division] : Division.all
      @entity = "clinics"
      render :wait_times
    else
      @data = nil
    end

    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @report = Report.new
    @ReportType = Report::ReportType
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @report = Report.new(params[:report])
    if @report.save
      redirect_to @report, :notice => "Successfully created report."
      else
      render :action => 'new'
    end
  end

  def edit
    @report = Report.find(params[:id])
    @ReportType = Report::ReportType
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @report = Report.find(params[:id])
    if @report.update_attributes(params[:report])
      redirect_to @report, :notice  => "Successfully updated report."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    redirect_to reports_url, :notice => "Successfully deleted report."
  end
end
