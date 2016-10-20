class Admin::MetricsController < AdminBaseController
  before_filter :parse_start_and_end_dates, only: [:index]

  def index
    get_kpi
    respond_to do |format| 
      format.html
      format.csv do 
        data = FinancialsReporterService.to_csv @sdate, @edate
        send_data data, filename: "kpi-#{@sdate}-#{@edate}.csv" 
      end 
    end
  end

  def get_kpi
    if @sdate && @edate
      @kpi = Metrics.by_start_and_end @sdate,@edate
    else
      @kpi, @sdate, @edate = Metrics.current_week_with_date_range
    end
  end
end
