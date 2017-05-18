var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.groupedBarGraphTemplate = function($chart){

  var series = $.map($chart.data("seriesNames"), function(name, i) {
    return { name: name, color: $chart.data("colorList")[i] };
  });

  return {
    chart: {
      type: 'column',
      spacingBottom: 60
    },
    legend: Airbo.Highcharts.Legend.defaultLegend($chart),
    series: series,
  };
};
