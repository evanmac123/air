var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.tileActivityTemplate = function($chart, data) {
  return {
    chart: {
      marginTop: 5,
      spacingBottom: 78,
      height: 275
    },
    yAxis: {
      tickPixelInterval: 40
    }
  };
};
