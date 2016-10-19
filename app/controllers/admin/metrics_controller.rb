require 'custom_responder'
class Admin::MetricsController < AdminBaseController
  include CustomResponder

  def index
    @kpi =if @sdate && @edate 
            Metrics.by_start_and_end @sdate,@edate
          else
            @sdate, @edate = Metrics.default_date_range
            Metrics.current_week
          end
    respond_to do |format| 
      format.html
      format.csv do 
        data = FinancialsReporterService.to_csv @sdate, @edate
        send_data data, filename: "kpi-#{@sdate}-#{@edate}.csv" 
      end 
    end
  end
  
  def historical
    FinancialsReporterService.delay.build_historical
    flash[:success]="Processing your historical metrics please check back in a few minutes"
    redirect_to organization_metrics_path
  end

  def metrics_recalc
    @kpi = Metrics.by_start_and_end @sdate,@edate
    render :metrics
  end



  private


end
