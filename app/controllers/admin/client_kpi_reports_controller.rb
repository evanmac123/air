class Admin::ClientKpiReportsController < AdminBaseController
  def show
    @report_data = Reporting::ClientKPIReport.get_weekly_report_data
  end
end
  # before_filter :parse_start_and_end_dates
  # def show
  #   @demos = Demo.paid
  #   report = Reporting::ClientUsage.new({demo: params[:demo_id], beg_date:@sdate, end_date:@edate, interval:params[:interval]})
  #   @report = present(report,ClientKpiReportPresenter)
  #   respond_to do |format|
  #     format.html
  #     format.csv do
  #       data = @report.to_csv
  #       send_data data, filename: "kpi-#{@sdate}-#{@edate}.csv"
  #     end
  #   end
  # end
