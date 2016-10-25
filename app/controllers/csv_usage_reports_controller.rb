class CsvUsageReportsController < ApplicationController
  def new
    authorize! :view_report, :csv_usage

    @submit_path = "/csv_usage_reports"
    @months = AnalyticsChartMonths.exec
    @scopes = current_user.reporting_divisions.map do |division|
      [ division.name, division.id ]
    end << ["All Divisions", "global"]
  end

  def create
    authorize! :view_report, :csv_usage

    if params[:scope] != "global" && !current_user.reporting_divisions.map(&:id).include?(params[:scope].to_i)
      raise "Not in your division"
    end

    PrepareUsageReport.call(AnalyticsChartMonths.parse(params).merge(
      division_id: (params[:scope] == "global" ? nil : params[:scope]),
      user: current_user,
      delay: true
    ))

    render nothing: true, status: 200
  end

  def show
    authorize! :view_report, :csv_usage

    send_data Pathways::S3.usage_reports_bucket.objects[params[:id]].read,
      filename: "pathways_usage_report_(retrieved_#{Date.current.strftime("%Y-%m-%d")}).csv"
  end
end
