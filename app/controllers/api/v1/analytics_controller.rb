module API
  module V1
    class Analytics
      # For time series data
      def show
        {


        }

        # options are start date, end date, division_id, user_type_key, path
        Analytics::WebPresenter.time_series(metric, params[:options])
      end
    end
  end
end
