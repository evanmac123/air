var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.defaultTemplate = function($chart) {
  var series = $.map($chart.data("seriesNames"), function(name) {
    return { name: name };
  });

  return {
    chart: {
      type: "line",
      height: 450,
      marginTop: 50,
      spacingBottom: 60
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    exporting: Airbo.Highcharts.Exporting.defaultExportingConfig($chart),
    xAxis: {
      type: "datetime",

      labels: {
        formatter: function() {
          return Airbo.Highcharts.Labels.defaultLabelFormatter(this, $chart);
        },
        style: {
          color: "#33445c"
        }
      },
      tickColor: "white"
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
      plotLines: [
        {
          value: 0,
          width: 1,
          color: "#d2dade"
        }
      ]
    },
    series: series,
    legend: Airbo.Highcharts.Legend.defaultLegend($chart),
    credits: { enabled: false },
    plotOptions: Airbo.Highcharts.PlotOptions.defaultPlotOptions($chart),
    tooltip: Airbo.Highcharts.CustomTooltips.SharedTooltipWithPercentChange.render(
      $chart
    )
  };
};
