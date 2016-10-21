class Admin::Financials::KpiDashboardController < AdminBaseController

  def show
    @kpi=nil
    get_dates
    @plot_data = FinancialsReporterService.plot_data_by_date @sdate, @edate
  end


  private

  def get_dates
    @sdate, @edate = FinancialsReporterService.default_date_range

  end


end

