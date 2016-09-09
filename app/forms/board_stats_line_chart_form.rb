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
     ['activity_sessions','tile_views', 'interactions' ]
   end

   def report_interval
     period.time_unit
   end


   # FIXME this feels a bit hacky. Seems like dates should in right format 
   # by the time we are here (TimeHandler?)  but is fine for now.

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

   def actions_taken
     @board.acts.count
   end

   def users_joined
     @board.users.claimed.count
   end

   def activity_sessions
     @new_chart ? "0" : @sessions_total
   end

   def interactions
     @new_chart ? "" : @board.tile_completions.count
   end

   def tiles_posted
      @board.tiles.active.count
   end

   private

  
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
        get_report
     end
   end

   def get_report
     if action_type=="activity_sessions"
       aggregation =  @value_type == "cumulative" ? "general" : "unique"
       @report = Reporting::Mixpanel::UniqueActivitySessionByBoard.new({demo_id:@board.id, type: aggregation, unit: report_interval, from_date: @start_date, to_date: @end_date})

       build_mixpanel_report_data
     else
       @report = Reporting::ClientUsage.new({demo: @board.id, beg_date: @start_date, end_date: @end_date , interval: report_interval})
       build_db_report_data
     end
   end

   def build_db_report_data
     aggregation =  @value_type == "cumulative" ? :total : :current
     @plot_data ||=  @report.series_for_key(series_key, aggregation)
   end

   def build_mixpanel_report_data
     @plot_data = Hash[@report.data.sort].values
     @sessions_total = @plot_data.sum
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

