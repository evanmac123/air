class Admin::ClientKpiReportsController < AdminBaseController
  before_filter :get_dates

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
