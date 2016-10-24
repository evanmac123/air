class Admin::Financials::KpiDashboardController < AdminBaseController
  before_filter :parse_start_and_end_dates, only: [:show]
  before_filter :get_dates, only: [:show]
  def show
    @table_data = FinancialsReporterService.get_data_by_date @sdate,@edate
    @dates = @table_data.delete("weekending_date")["values"]
    @totals= FinancialsReporterService.totals
   @plot_data=@table_data["starting_mrr"]["values"]
    if request.xhr?
      render json: {plotData: @plot_data, totals: @totals, tableData: @kpi}
    end
  end


  private

  def get_dates
    if !(@sdate && @edate)
      @sdate, @edate = FinancialsReporterService.default_date_range
    end
  end


end

