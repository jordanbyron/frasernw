module Api
  module V1
    class ReportsController < ApplicationController
      def page_views
        authorize! :view_report, :page_views

        start_month = Month.from_i(params[:start_month])
        end_month = Month.from_i(params[:end_month])

        @chart_data = PageViewsChart.exec(
          start_date: start_month.start_date,
          end_date: end_month.end_date
        )

        render json: @chart_data
      end
    end
  end
end
