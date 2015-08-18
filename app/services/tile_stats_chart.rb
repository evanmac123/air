class TileStatsChart
  attr_reader :tile, :content, :point_interval, :start_date, :end_date, :value_type
  # CONTENT = ['unique_views', 'total_views', 'interactions']
  # INTERVAL = ['monthly', 'weekly', 'daily', 'hourly']
  # VALUE_TYPE = ['cumulative', 'activity']

  def initialize tile, params = {}
    @tile = tile
    @content = params[:content] || 'unqiue_views'
    @point_interval = params[:point_interval] || 'daily'
    @start_date = params[:start_date] || tile.created_at.to_s(:chart_start_end_day)
    @end_date = params[:end_date] || Time.now.to_s(:chart_start_end_day)
    @value_type = params[:value_type] || 'cumulative'
  end

  def draw
    LazyHighCharts::HighChart.new do |hc|
      hc.exporting exporting_params
      hc.legend legend_params
      hc.xAxis x_axis_params
      hc.yAxis y_axis_params
      hc.plotOptions plot_options_params
      hc.series name: 'Unique views',  data: (0..23).to_a
    end
  end

  protected
    # export to PNG, JPEG, PDF, SVG
    # Remove 'Print'
    def exporting_params
      {
        buttons: { 
          printButton: { 
            enabled: false 
          }
        }
      }
    end

    def legend_params
      { layout: 'horizontal' }
    end

    def x_axis_params
      {
        title: { 
          text: nil 
        }, 
        type: 'datetime', 
        maxPadding: 0.02, 
        labels: {
          formatter: x_axis_label.js_code
        }
      }
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%l %p', this.value); }"
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
      60 * 60
    end
end
