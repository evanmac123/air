class Admin::ClientKpiReportsController < AdminBaseController
  before_filter :parse_start_and_end_dates, only: [:show]
  before_filter :get_dates, only: [:show]

  def show
    @rep = Reporting::ClientKPIReport.new
    @table_data = @rep.get_data_by_date_and_interval @sdate,@edate, params[:interval] || Metrics::WEEKLY
    
    @dates = @table_data["from_date"]["values"]
    if request.xhr?
      render partial: "table_with_chart_data"
    end
  end

  private

  def get_dates
    if !(@sdate && @edate)
      @sdate, @edate = Reporting::ClientKPIReport.new.default_date_range
    end
  end
end
