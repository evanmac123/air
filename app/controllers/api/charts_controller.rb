module Api
  class ChartsController < Api::ClientAdminBaseController
    def show
      chart = chart_class.new(chart_params)

      render json: {
        data: {
          attributes: chart.attributes(requested_series_list)
        }
      }
    end

    private

      def chart_params
        params.require(:chart_params).permit(
          :chart_type,
          :interval_type,
          :start_date,
          :end_date,
          :demo_id
        )
      end

      def requested_series_list
        params[:chart_params][:requested_series_list] || ["primary_data"]
      end

      def chart_class
        params[:chart_params][:chart_type].constantize
      end
  end
end
