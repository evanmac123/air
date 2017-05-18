var Airbo = window.Airbo || {};
Airbo.Highcharts = Airbo.Highcharts || {};

Airbo.Highcharts.loginActivityTilesDigestTemplate = function($chart, data){
  var tilesDigestYAxisMax;

  if (data) {
    var tilesDigestYAxisData = data.series[1].data;
    tilesDigestYAxisMax = Airbo.HighchartsBase.axisMax(tilesDigestYAxisData);
  }

  var zIndex = $chart.data("seriesNames").length;
  var series = $.map($chart.data("seriesNames"), function(name, i) {
    var configIndex;
    if (i === 0) {
      configIndex = i;
    } else {
      configIndex = 1;
    }

    var seriesVisible = name === "Follow Up Emails Sent" ? false : true;

    s =  { name: name, type: $chart.data("chartTypes")[configIndex], color: $chart.data("colorList")[i], yAxis: configIndex, zIndex: zIndex, visible: seriesVisible };

    zIndex--;
    return s;
  });

  return {
    chart: {
      type: null,
      zoomType: 'xy'
    },
    exporting: {
      chartOptions: {
        yAxis: [{
          labels: {
            enabled: true
          },
          title: {
            text: "Logins"
          }
        },
        {
          max: tilesDigestYAxisMax * 3,
          allowDecimals: false,
          gridLineColor: 'transparent',
          opposite: true,
          labels: {
            enabled: true
          },
          title: {
            text: "Emails Sent"
          }
        }]
      }
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
    series: series,
  };
};
