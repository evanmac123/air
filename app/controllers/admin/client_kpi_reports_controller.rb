class Admin::ClientKpiReportsController < AdminBaseController
  before_filter :parse_start_and_end_dates, only: [:show]
  before_filter :get_dates, only: [:show]

  def show
    rep = Reporting::ClientKPIReport.new
    @table_data = rep.get_data_by_date(@sdate, @edate)
    @dates = @table_data["report_date"]["values"]
  end

  private

  def get_dates
    if !(@sdate && @edate)
      @sdate, @edate = Reporting::ClientKPIReport.new.default_date_range
    end
  end
end
