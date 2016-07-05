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

      def entity_page_views
        authorize! :view_report, :entity_page_views

        if current_user.as_admin? &&
          params[:division_id] != "0" &&
          !current_user.as_divisions.map(&:id).include?(params[:division_id].to_i)

          raise "Unauthorized"
        end

        render json: {
          recordsToDisplay: EntityPageViewsReport.call(
            start_month_key: params[:start_month_key],
            end_month_key: params[:end_month_key],
            division_id: params[:division_id],
            record_type: params[:record_type].underscore.to_sym
          )
        }
      end

      def user_ids
        authorize! :view_report, :user_ids

        render json: AnalyticsChart.exec(AnalyticsChartMonths.parse(params).merge(
          metric: :user_ids,
          divisions: current_user.reporting_divisions,
          force: false
        ))
      end

      def pageviews_by_user
        authorize! :view_reports, :pageviews_by_user

        render json: {
          recordsToDisplay: PageviewsByUser.call(
            start_month: Month.from_i(params[:data][:startMonth].to_i),
            end_month: Month.from_i(params[:data][:endMonth].to_i),
            division_id: params[:data][:divisionId].to_i
          )
        }
      end
    end
  end
end
