class Admin::Financials::KpiDashboardController < AdminBaseController
  before_filter :parse_start_and_end_dates, only: [:show]
  def show
    get_kpi
    @plot_data = FinancialsReporterService.plot_data_by_date @sdate, @edate
    @totals= FinancialsReporterService.totals
    if request.xhr?
      render json: {series: @plot_data.to_json, totals: @totals.to_json, table_data: @kpi.to_json}
    end
  end


  private

  def get_dates
    if !(@sdate && @edate)
      @sdate, @edate = FinancialsReporterService.default_date_range
    end
  end

  def get_kpi
    get_dates
    @kpi = Metrics.by_start_and_end @sdate,@edate
  end
end

