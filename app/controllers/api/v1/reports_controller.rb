module Api
  module V1
    class ReportsController < ApplicationController
      def page_views
        authorize! :view_report, :page_views

        render json: AnalyticsChart.exec(AnalyticsChartMonths.parse(params).merge(
          metric: :page_views,
          divisions: current_user.reporting_divisions,
          force: false
        ))
      end

      def sessions
        authorize! :view_report, :sessions

        render json: AnalyticsChart.exec(AnalyticsChartMonths.parse(params).merge(
          metric: :sessions,
          divisions: current_user.reporting_divisions,
          force: false
        ))
      end

      def usage
        authorize! :view_report, :usage

        # unless user.super_admin?
        #   raise
        # end

        render json: {
          rows: WebUsageReport.exec(
            month_key: params[:month_key],
            division_id: params[:division_id],
            record_type: params[:record_type].underscore.to_sym
          )
        }
      end
    end
  end
end
