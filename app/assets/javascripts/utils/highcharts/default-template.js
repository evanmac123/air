var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.defaultTemplate = function($chart){
  var series = $.map($chart.data("seriesNames"), function(name) {
    return { name: name };
  });

  return {
    chart: {
      type: 'line',
      height: 500,
      marginTop: 100,
      spacingBottom: 60
    },
    responsive: {
      rules: [
        {
          condition: {
            maxWidth: 768
          },
          chartOptions: {
            subtitle: {
              text: null
            }
          }
        }
      ]
    },
    loading: {
      style: {

      }
    },
    exporting: Airbo.Utils.Highcharts.Exporting.defaultExportingConfig(),
    title: {
      text: $chart.data("title"),
      align: "left",
      style: {
        color: $chart.data("chartHeaderColor"),
        fontWeight: "bold"
      }
    },
    subtitle: {
      text: $chart.data("subtitle"),
      align: "left",
      style: {
        color: $chart.data("chartSubHeaderColor"),
        fontSize: "16px"
      }
    },
    xAxis: {
      type: 'datetime',

      labels: {
        align: 'center',
        format: Airbo.Utils.Highcharts.Labels.defaultLabelFormat($chart),
        style: {
          color: "#33445c"
        }
      },
      tickColor: 'white'
    },
    yAxis: {
      title: {
        text: null
      },
      allowDecimals: false,
      gridLineColor: "#d2dade",
      labels: {
        style: {
          color: "#33445c"
        }
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#d2dade'
      }]
    },
    series: series,
    legend: Airbo.Utils.Highcharts.Legend.defaultLegend($chart),
    credits: { enabled: false },
    plotOptions: Airbo.Utils.Highcharts.PlotOptions.defaultPlotOptions($chart),
    tooltip: Airbo.Utils.Highcharts.Tooltip.defaultTooltip($chart)
  };
};
