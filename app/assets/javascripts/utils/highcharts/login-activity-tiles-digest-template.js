var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.loginActivityTilesDigestTemplate = function($chart, data){
  var tilesDigestYAxisMax;

  if (data) {
    var tilesDigestYAxisData = data.series[1].data;
    tilesDigestYAxisMax = Airbo.Utils.HighchartsBase.axisMax(tilesDigestYAxisData);
  }

  var zIndex = $chart.data("seriesNames").length;
  var series = $.map($chart.data("seriesNames"), function(name, i) {
    s =  { name: name, type: $chart.data("chartTypes")[i], color: $chart.data("colorList")[i], yAxis: i, zIndex: zIndex };

    zIndex--;
    return s;
  });

  return {
    chart: {
      type: null,
      zoomType: 'xy'
    },
    yAxis: [{ // Primary yAxis
        min: 0,
        tickAmount: 5,
        labels: {

        },
        title: {
          text: null
        }
    }, { // Secondary yAxis
    		max: tilesDigestYAxisMax * 3,
        gridLineColor: 'transparent',
        title: {
            text: null
        },
        labels: {
        	enabled: false
        },
        opposite: true
    }],
    series: series
  };
};
