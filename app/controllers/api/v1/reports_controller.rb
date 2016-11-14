module Api
  module V1
    class ReportsController < ApplicationController

      def analytics_charts
        authorize! :view_report, params[:metric].to_sym

        render json: AnalyticsChart.call({
          metric: params[:metric].to_sym,
          divisions: current_user.reporting_divisions,
          user_type_key: params[:user_type_key].to_i
        }.merge(params.slice(:start_month_key, :end_month_key)))
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

      def page_views_by_user
        authorize! :view_reports, :page_views_by_user

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
