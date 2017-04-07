var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.Highcharts = Airbo.Utils.Highcharts || {};

Airbo.Utils.Highcharts.circlePercentTemplate = function($chart){
  return {
    chart: {
      type: 'solidgauge',
      backgroundColor: '#33445c',
      height: 280,
      width: 280
    },

    title: null,

    tooltip: {
      enabled: false
    },

    pane: {
      startAngle: 0,
      endAngle: 360,
      background: {
        outerRadius: '110%',
        innerRadius: '88%',
        backgroundColor: '#2b3a4f',
        borderWidth: 0
      }
    },

    yAxis: {
      min: 0,
      max: 100,
      lineWidth: 0,
      tickPositions: []
    },

    plotOptions: {
      solidgauge: {
        dataLabels: {
        	verticalAlign: 'top',
          borderWidth: 0,
          useHTML: true,
          format: '<div class="circle-graph-label"><span class="num">{y}%</span><br><span class="label">Logged On</span></div>'
        }
      }
    },

    credits: {
      enabled: false
    },

    series: [{
      data: [{
        color: '#48bfff',
        radius: '110%',
        innerRadius: '88%',
        y: 0
      }]
    }]
  };
};
