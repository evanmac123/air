class Admin::HistoricalMetricsController < AdminBaseController

  def create
    FinancialsReporterService.delay.build_historical
    flash[:success]="Processing your historical metrics please check back in a few minutes"
    redirect_to admin_metrics_path
  end

end
