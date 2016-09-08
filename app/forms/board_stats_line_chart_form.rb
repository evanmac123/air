 class BoardStatsLineChartForm < LineChartReportForm
   def initialize board, params = {}
     @board = board
     super params
     pull_data
   end

   def plot_data
     #TODO create a struct or similar object that has a values and max_value
     #method that returns the desired subset of the data from the @data and

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
     @start_date = parse_date(params["start_date"])
     @end_date = parse_date(params["end_date"])
   end

   def parse_date str
     Time.strptime(str, "%b %d, %Y")
   end

   def action_type_class action
     # TODO: this method needs to be here for the UI
     action + " " + (action == action_type ? "selected" : "")
   end

   def action_num(action)
     #FIXME
     100
   end

   private

   def build_report_data
     @plot_data ||=  @report.series_for_key([:tile_activity, :views], :current)
   end

   def build_null_data
     @plot_data = [0]
   end

   def activations
     # TODO: Is this what you have in mind here? Or just another hit to the DB?
     @data[:user][:activations].map { |a| a[1][:total] }.inject(:+)
   end


   def pull_data
     if @new_chart
       build_null_data
     else
       @report =  Reporting::ClientUsage.new({demo: @board.id, start: @start_date, end_date: @end_date , interval: report_interval})
       build_report_data
     end
   end

     def initial_params
       {
         start_date: @board.created_at.strftime("%b %d, %Y"),
         end_date: Time.now.strftime("%b %d, %Y"),
         changed_field: 'end_date', # to trigger time handler
         new_chart: true
       }
     end
 end

