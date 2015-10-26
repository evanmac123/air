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
        backgroundColor: "#fafafa",
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
        allowHTML: true,
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
        offset: 10,
        labels: {
          align: 'center',
          style: {
            color: '#a8a8a8',
            'font-weight' => 700
          },
          useHTML: true
        },
        tickColor: 'white',
        maxPadding: 0.04,
        minPadding: 0.04
      }
    end

    def y_axis_params
      {
        allowDecimals: false,
        gridLineColor: '#d6d6d6',
        offset: 7,
        labels: {
          style: {
            color: '#a8a8a8',
            'font-weight' => 700
          },
          useHTML: true
        },
        title: {
          text: nil
        },
        min: 0,
        max: (plot_data.data.max == 0 ? 10 : nil), # set max when there is no data to draw y axis lines
        tickPixelInterval: 47
      }
    end

    def plot_options_params
      {
        line: {
          pointStart: period.start_date(:date),
          # FIXME maybe - Carly Rae Jepsen
          # 0.001 is set if interval is month. gem multiplies it by 1000 to get Milliseconds.
          # so it's 1 in the end. And then pointIntervalUnit is used for monthes.
          pointInterval: (period.point_interval_unit ? 0.001 : period.point_interval),
          pointIntervalUnit: period.point_interval_unit,
          lineWidth: 3,
          shadow: false,
          marker: {
            radius: 5
          }
        }
      }
    end

    def tooltip_params
      {
        useHTML: true,
        style: {
          padding: 8,
          fontSize: 13
        },
        headerFormat: "<div style='color:{series.color};'>{point.key}</div>",
        pointFormat: "<div style='padding-top:3px;'>{point.y}</div>",
        shadow: false
      }
    end

    def series_params
      {
        data: plot_data.data,
        color: '#4FACE0'
      }
    end
end
