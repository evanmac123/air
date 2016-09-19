 class BoardStatsLineChartForm < LineChartReportForm
   def initialize board, params = {}
     @board = board
     super params
     parse_dates
     pull_data
   end

   def plot_data
     OpenStruct.new(:values => @plot_data.map{|x|x.round(2)}, :max_value => @plot_data.max)
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
     @new_chart ? "" : life_time_sessions
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

   #TODO explore more elegant way of pulling mixpanel data along with db data

   def get_report
     if action_type=="activity_sessions"
       aggregation =  @value_type == "cumulative" ? "general" : "unique"
       report  = pull_mixpanel(aggregation, @start_date, @end_date)
       series =  mixpanel_series_from report, aggregation 
       @plot_data = series
     else
       report = Reporting::ClientUsage.new({demo: @board.id, beg_date: @start_date, end_date: @end_date , interval: report_interval})
       build_db_report_data report
     end
   end

   def pull_mixpanel aggregation, start_date, end_date
     Reporting::Mixpanel::UniqueActivitySessionByBoard.new({demo_id:@board.id, type: aggregation, unit: report_interval, from_date: start_date, to_date: end_date})
   end


   def life_time_sessions
     report = pull_mixpanel("general", @board.created_at.to_date, Date.today)
     series = mixpanel_series_from(report, "general")
     series.sum
   end

   def build_db_report_data report
     aggregation =  @value_type == "cumulative" ? :total : :current
     @plot_data ||=  report.series_for_key(series_key, aggregation)
   end

   def mixpanel_series_from report, aggregation
     data = Hash[report.data.sort].values
     if(aggregation == "general")
       sum = 0
       data = data.map{|val|sum += val}
     end
     data
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
