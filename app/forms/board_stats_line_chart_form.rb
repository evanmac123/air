class BoardStatsLineChartForm < LineChartReportForm
  def initialize board, params = {}
    @board = board
    super params
    #TODO make sure you can pull the data here 
    pull_data
  end



  def plot_data
    #TODO create a struct or similar object that has a values and max_value
    #method that returns the desired subset of the data from the @data and
    #max_value from that data series
    @data
  end


  def self.model_name
    ActiveModel::Name.new(BoardStatsLineChartForm)
  end

  def action_types
    #TODO change to match data structure returned from Reporting::ClientUsage
   ['unique_views', 'total_views', 'interactions']
  end

  def report_interval
    period.time_unit
  end

  def parse_dates
    @start_date = parse_date(params["start_date"])
    @end_date = parse_date(params["end_date"])
  end

  def parse_date str
    Time.strptime(str, "%b %d, %Y")
  end

  private

  def pull_data
   @data =  Reporting::ClientUsage.new({demo:@board.id, start: @start_date, end_date: @end_date , interval: report_interval}).data
  end



end
