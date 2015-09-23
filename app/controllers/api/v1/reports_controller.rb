module Api
  module V1
    class ReportsController < ApplicationController
      def page_views
        authorize! :view_report, :page_views

        render json: AnalyticsChart.exec(chart_dates(params).merge(
          metric: :page_views
        ))
      end

      def sessions
        authorize! :view_report, :sessions

        render json: AnalyticsChart.exec(chart_dates(params).merge(
          metric: :sessions
        ))
      end

      private

      def chart_dates(params)
        {
          start_date: Month.from_i(params[:start_month]).start_date,
          end_date: Month.from_i(params[:end_month]).end_date
        }
      end
    end
  end
end
