class Admin::Financials::KpiDashboardController < AdminBaseController
  before_filter :parse_start_and_end_dates, only: [:show]
  before_filter :get_dates, only: [:show]
  def show
    @dates = @table_data["report_date"]["values"] || []
    @table_data = FinancialsReporterService.get_data_by_date_and_interval @sdate,@edate
    @totals= FinancialsReporterService.totals
    if request.xhr?
      #render json: {totals: @totals, tableData: @table_data}
      render partial: "table_with_chart_data"
    end
  end


  private

  def get_dates
    if !(@sdate && @edate)
      @sdate, @edate = FinancialsReporterService.default_date_range
    end
  end


end

