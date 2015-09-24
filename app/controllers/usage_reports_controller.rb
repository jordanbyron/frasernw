class UsageReportsController < ApplicationController
  def new
    authorize! :view_report, :usage

    @submit_path = usage_reports_path
    @months = AnalyticsChartMonths.exec
    @scopes = Division.all.reject do |division|
      division.name == "Vancouver (Hidden)" || division.name == "Provincial"
    end.map do |division|
      [ division.name, division.id ]
    end << ["All Divisions", "global"]
  end

  def create
    authorize! :view_report, :usage

    PrepareUsageReport.delay.exec(AnalyticsChartMonths.parse(params).merge(
      division_id: (params[:scope] == "global" ? nil : params[:scope])
    ))
  end

  def show
    authorize! :view_report, :usage

    csv_string = S3.bucket[params[:id]].read

    render plain: csv_string,
      content_type: :csv
  end
end
