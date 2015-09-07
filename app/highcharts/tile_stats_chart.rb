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
        lineWidth: 0,
        dateTimeLabelFormats: {
        	day: "%b %d",
        	week: "%b %d",
        	month: '%b %Y',
        	year: '%Y'
        },
        offset: 15,
        labels: {
          align: 'left',
          style: {
            color: '#cecece',
            'font-weight' => 700
          },
          useHTML: true
        },
        tickColor: 'white',
        # tickInterval: 5
        # tickPositioner: tick_positioner
      }
    end

#     def tick_positioner
#       <<-JS
#       function() {
#         return
#       }
# JS
#     end

    def y_axis_params
      {
        # allowDecimals: false,
        gridLineColor: '#e3e3e3',
        offset: 15,
        labels: {
          style: {
            color: '#cecece',
            'font-weight' => 700
          },
          useHTML: true
        },
        title: {
          text: nil
        },
        min: 0,
        tickPixelInterval: 50
      }
    end

    def plot_options_params
      {
        line: {
          pointStart: period.start_date(:date),
          pointInterval: period.point_interval,
          shadow: false,
          # stacking: 'percent'
        }
      }
    end

    def tooltip_params
      {
        #formatter: tooltip_formatter.js_code
        # borderColor:
        useHTML: true,
        style: {
          padding: 8,
          fontSize: 13
        },
        headerFormat: "<div style='color:{series.color};'>{point.key}</div>",
        pointFormat: "<div style='padding-top:3px;'>{point.y}</div>",
        shadow: false
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

#     def tooltip_formatter
#       <<-JS
#       function () {
#         return 'The value for <b>' +
#           Highcharts.dateFormat('%l %p', this.x) +
#           '</b> is <b>' + this.y + '</b>';
#       }
# JS
#     end

    def series_params
      {
        data: plot_data.data,
        color: '#2aa4eb'
      }
    end
end
