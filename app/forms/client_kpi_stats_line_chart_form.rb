 class ClientKpiStatsLineChartForm < LineChartReportForm
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
     ActiveModel::Name.new(ClientKpiStatsLineChartForm)
   end

   def action_types
     ['mrr' ]
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

   def mrr
     @new_chart ? "" : Metrics. 
   end


   private

   def build_null_data
     @plot_data = [0]
   end

   def series_key
      case action_type
       when "mrr"
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
     report = Reporting::ClientKpi.new({beg_date: @start_date, end_date: @end_date , interval: report_interval})
     build_db_report_data report
   end

   def build_db_report_data report
     aggregation =  @value_type == "cumulative" ? :total : :current
     @plot_data ||=  report.series_for_key(series_key, aggregation)
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
