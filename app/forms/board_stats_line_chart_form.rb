 class BoardStatsLineChartForm < LineChartReportForm
   def initialize board, params = {}
     @board = board
     super params
     parse_dates
     pull_data
   end

   def plot_data
     OpenStruct.new(:values => @plot_data, :max_value => @plot_data.max)
   end


   def self.model_name
     ActiveModel::Name.new(BoardStatsLineChartForm)
   end

   def action_types
    ['tile_views', 'activations', 'activity_sessions', 'interactions']
   end

   def report_interval
     period.time_unit
   end

   def parse_dates
     @start_date = parse_date(start_date)
     @end_date = parse_date(end_date)
   end

   def parse_date str
     Time.strptime(str, "%b %d, %Y")
   end

   def tile_views
     @new_chart ? "" : @board.tile_viewings.count
   end

   def activations
     @new_chart ? "" : @board.users.claimed.count
   end

   def activity_sessions
     @new_chart ? "" : "-"
   end

   def interactions
     @new_chart ? "" : @board.tile_completions.count
   end

   private

   def build_report_data

   aggregation =  @value_type == "cumulative" ? :total : :current

   @plot_data ||=  @report.series_for_key(series_key, aggregation)
   end

   def build_null_data
     @plot_data = [0]
   end


   def series_key
      case action_type
       when "tile_views"
         [:tile_activity, :views]
       when "interactions"
         [:tile_activity, :completions]
       when "activations"
         [:user, :activations]
       when "activity_sessions"
         [:tile_activity, :views]
      end
   end


   def pull_data
     if @new_chart
       build_null_data
     else
       @report =  Reporting::ClientUsage.new({demo: @board.id, beg_date: @start_date, end_date: @end_date , interval: report_interval})

       build_report_data
     end
   end

     def initial_params
       {
         start_date: 3.months.ago.strftime("%b %d, %Y"),
         end_date: Time.now.strftime("%b %d, %Y"),
         changed_field: 'end_date', # to trigger time handler
         new_chart: true
       }
     end
 end

