class TileStatsChart
  attr_reader :tile, :content, :point_interval, :start_date, :end_date, :value_type
  # CONTENT = ['unique_views', 'total_views', 'interactions']
  # INTERVAL = ['monthly', 'weekly', 'daily', 'hourly']
  # VALUE_TYPE = ['cumulative', 'activity']

  def initialize tile, params = {}
    @tile = tile
    @content = params[:content] || 'unqiue_views'
    @point_interval = params[:point_interval] || 'daily'
    # date_range
    @start_date = params[:start_date] || (Time.now - 1.day).to_s(:chart_start_end_day) #tile.created_at.to_s(:chart_start_end_day)
    @end_date = params[:end_date] || Time.now.to_s(:chart_start_end_day)
    @value_type = params[:value_type] || 'cumulative'
  end

  def draw
    LazyHighCharts::HighChart.new do |hc|
      hc.chart chart_params
      hc.exporting exporting_params
      hc.legend legend_params
      hc.xAxis x_axis_params
      hc.yAxis y_axis_params
      hc.plotOptions plot_options_params
      hc.tooltip tooltip_params
      hc.series name: 'Unique views',  data: data
    end
  end

  protected
    def chart_params
      { 
        events: {
          load: load_function.js_code 
        }
      }
    end

    def load_function
      # makes custom foundation selectors
      <<-JS
      function() { 
        return $(document).foundation();
      }
JS
    end

    def exporting_params
      # export to PNG, JPEG, PDF, SVG
      # Remove 'Print'
      {
        buttons: { 
          printButton: { 
            enabled: false 
          }
        }
      }
    end

    def legend_params
      { enabled: false }
    end

    def x_axis_params
      {
        title: { 
          text: nil 
        }, 
        type: 'datetime', 
        #maxPadding: 0.02, 
        labels: {
          formatter: x_axis_label.js_code
        }
      }
    end

    def x_axis_label
      <<-JS
      function() { 
        return Highcharts.dateFormat('%l %p', this.value); 
      }
JS
    end

    def y_axis_params
      {
        title: {
          text: nil
        }, 
        min: 0
      }
    end

    def plot_options_params
      {
        line: {
          pointStart: Highchart.convert_date(start_date).to_date, 
          pointInterval: point_interval
        }
      }
    end

    def point_interval
      1.hour
    end

    def data
      #(0..23).to_a
      @q_start_date = Highchart.convert_date(@start_date).beginning_of_day
      @q_end_date = Highchart.convert_date(@end_date).end_of_day

      grouped_views = tile.tile_viewings
          .select("date_trunc('#{time_unit}', created_at), views")
          .where(created_at: @q_start_date..@q_end_date)
          .group("date_trunc('#{time_unit}', created_at)")
          .sum(:views)
      # => {"2015-08-19 11:00:00"=>12, "2015-08-19 10:00:00"=>27, "2015-08-19 13:00:00"=>1, "2015-08-19 09:00:00"=>3, "2015-08-19 12:00:00"=>15}
      start = @q_start_date
      stop  = @q_end_date
      while start < stop
        grouped_views[start] = grouped_views[start] || 0
        start += 1.send(time_unit.to_sym)
      end
      grouped_views.values
    end

    def time_unit
      'hour'
    end

    def tooltip_params
      #{formatter: tooltip_formatter.js_code }
      {}
    end

#     def tooltip_formatter
#       <<-JS
#       function () {
#         return 'The value for <b>' + 
#           Highcharts.dateFormat('%l %p', this.x) +
#           //Object.getOwnPropertyNames(this) +
#           Object.getOwnPropertyNames(this.point) +
#           this.point.state() +
#           '</b> is <b>' + this.y + '</b>';
#       }
# JS
#     end
end
