var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.groupedBarGraphTemplate = function($chart){

  var series = $.map($chart.data("seriesNames"), function(name, i) {
    return { name: name, color: $chart.data("colorList")[i] };
  });

  return {
    chart: {
      type: 'column',
      spacingBottom: 60
    },
    legend: Airbo.Utils.Highcharts.Legend.defaultLegend($chart),
    series: series
  };
};
