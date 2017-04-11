class Api::ClientAdmin::ReportsController < Api::ClientAdminBaseController
  def show
    report = report_class.new(
      report_params[:demo_id],
      report_params[:from_date],
      report_params[:to_date]
    )

    render json: {
      data: {
        attributes: report.attributes
      }
    }
  end

  private

    def report_params
      params.require(:report_params).permit(
        :from_date,
        :to_date,
        :demo_id
      )
    end

    def report_class
      params[:report_params][:report_type].constantize
    end
end
