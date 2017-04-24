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
      marginTop: 50,
      spacingBottom: 60
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    exporting: Airbo.Utils.Highcharts.Exporting.defaultExportingConfig($chart),
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
