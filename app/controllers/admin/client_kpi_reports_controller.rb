class Admin::ClientKpiReportsController < AdminBaseController
  def show
    @report_data = Reporting::ClientKPIReport.get_weekly_report_data
  end
end

