# class BoardStatsLineChartForm < LineChartReportForm
#   def initialize board, params = {}
#     @board = Demo.last
#     super params
#     #TODO make sure you can pull the data here
#     pull_data
#   end
#
#   def plot_data
#     #TODO create a struct or similar object that has a values and max_value
#     #method that returns the desired subset of the data from the @data and
#     #max_value from that data series
#     PlotData.new(period, @action_type, @value_type, @data)
#   end
#
#
#   def self.model_name
#     ActiveModel::Name.new(BoardStatsLineChartForm)
#   end
#
#   def action_types
#     #TODO change to match data structure returned from Reporting::ClientUsage
#     # TODO: Change Reporting::ClientUsage to match the below structure
#    ['activations', 'activity_sessions', 'views', 'interactions']
#   end
#
#   def report_interval
#     period.time_unit
#   end
#
#   def parse_dates
#     @start_date = parse_date(params["start_date"])
#     @end_date = parse_date(params["end_date"])
#   end
#
#   def parse_date str
#     Time.strptime(str, "%b %d, %Y")
#   end
#
#   def action_type_class action
#     # TODO: this method needs to be here for the UI
#     action + " " + (action == action_type ? "selected" : "")
#   end
#
#   def action_num(action)
#     self.send(action)
#   end
#
#   private
#
#   def activations
#     # TODO: Is this what you have in mind here? Or just another hit to the DB?
#     @data[:user][:activations].map { |a| a[1][:total] }.inject(:+)
#   end
#
#   def activity_sessions
#
#   end
#
#   def views
#     @data.tile_views
#   end
#
#   def interactions
#
#   end
#
#   def pull_data
#    @data =  Reporting::ClientUsage.new({demo: @board.id, start: @start_date, end_date: @end_date , interval: report_interval}).data
#   end
#
#     def initial_params
#       {
#         start_date: @board.created_at.strftime("%b %d, %Y"),
#         end_date: Time.now.strftime("%b %d, %Y"),
#         changed_field: 'end_date', # to trigger time handler
#         new_chart: true
#       }
#     end
# end
class BoardStatsLineChartForm < LineChartReportForm

  def initialize tile, params = {}
    @tile = tile
    super params

    @action_query = ("Query::" + action_type.camelize).constantize.new(tile, period)
  end

  def tile
    @tile
  end

  def action_types
   ['unique_views', 'total_views', 'interactions', 'interactions']
  end

  def action_num action
    tile.send(action.to_sym)
  end

  def action_type_class action
    action + " " + (action == action_type ? "selected" : "")
  end

  def plot_data
    PlotData.new( period, @action_query, @value_type)
  end

  # Implements ActiveModel methods

  def self.model_name
    ActiveModel::Name.new(BoardStatsLineChartForm)
  end

  protected

  def initial_params
    {
      start_date: tile.created_at.strftime("%b %d, %Y"),
      end_date: Time.now.strftime("%b %d, %Y"),
      changed_field: 'end_date', # to trigger time handler
      new_chart: true
    }
  end
end
