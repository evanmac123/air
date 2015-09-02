class TileStatsChart
  attr_reader :period, :plot_data

  def initialize period, action_query, value_type
    @period = period
    @plot_data = PlotData.new @period, action_query, value_type
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
      hc.series series_params
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
        # maxPadding: 0.02,
        labels: {
          formatter: x_axis_label.js_code
        }
      }
    end

    def x_axis_label
      <<-JS
      function() {
        return Highcharts.dateFormat('#{period.x_axis_label_format}', this.value);
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
          pointStart: period.start_date(:date),
          pointInterval: period.point_interval
        }
      }
    end

    def tooltip_params
      {
        #formatter: tooltip_formatter.js_code
        # borderColor:
        useHTML: true,
        headerFormat: "<div style='font-size:13px;color:{series.color};padding:3px;'>{point.key}</div>",
        pointFormat: "<div style='font-size:13px;padding:3px;padding-top:0;font-weight:700;'>{point.y}</div>"
      }
      #{}
    end

#     def point_format
#       <<-JS
#       function() {
#         return point.y;
#       }
# JS
#     end

    def tooltip_formatter
      <<-JS
      function () {
        return 'The value for <b>' +
          Highcharts.dateFormat('%l %p', this.x) +
          '</b> is <b>' + this.y + '</b>';
      }
JS
    end

    def series_params
      {
        data: plot_data.data,
        color: '#4FACE0'
      }
    end
end
