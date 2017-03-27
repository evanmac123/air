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
      height: 450,
      spacingBottom: 60
    },
    loading: {
      style: {

      }
    },
    exporting: {
      enabled: false
    },
    title: {
      text: $chart.data("title"),
      align: "left",
      style: { "color": $chart.data("chartHeaderColor"), "font-weight": "bold", "padding-bottom": "15px" }
    },
    subtitle: {
      text: $chart.data("subtitle"),
      align: "left",
      style: { "color": $chart.data("chartSubHeaderColor"), "font-size": "16px", "padding-bottom": "15px", "margin": "0" }
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
