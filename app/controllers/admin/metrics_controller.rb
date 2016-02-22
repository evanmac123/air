require 'custom_responder'
class Admin::MetricsController < AdminBaseController
  include CustomResponder


  def historical
    FinancialsReporterService.delay.build_historical
    flash[:success]="Processing your historical metrics please check back in a few minutes"
    redirect_to organization_metrics_path
  end

  private


end
