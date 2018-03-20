var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.stackedBarGraphTemplate = function($chart) {
  var legendIndex = $chart.data("seriesNames").length;
  var series = $.map($chart.data("seriesNames"), function(name, i) {
    legendIndex--;
    return {
      name: name,
      color: $chart.data("colorList")[i],
      legendIndex: legendIndex
    };
  });

  return {
    chart: {
      type: "column"
    },
    plotOptions: $.extend(
      Airbo.Highcharts.PlotOptions.defaultPlotOptions($chart),
      { column: { stacking: "normal" } }
    ),
    series: series,
    tooltip: Airbo.Highcharts.CustomTooltips.SharedTooltipWithPercentOfWhole.render(
      $chart
    )
  };
};
