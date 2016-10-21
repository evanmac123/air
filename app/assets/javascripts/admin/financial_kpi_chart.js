var Airbo = window.Airbo || {};

Airbo.FinancialKpiChart = (function(){

  function initChart(){
    var myChart = Highcharts.chart('container', {
      chart: {
        type: 'line'
      },
      title: {
        text: 'Monthly Recuring Revenue'
      },
      xAxis: x_axis_params() ,
      yAxis: y_axis_params(),
      series: [{
        data: $("#container").data("plotdata")
      } ]
    });
  }


  function legend_params(){
    return { enabled: false };
  } 

  function x_axis_params(){
    return   {
      title: {
        text: "" 
      },
      type: 'datetime',
      lineWidth: 0,
      dateTimeLabelFormats: {
        day: "%b %d",
        week: "%b %d",
        month: '%b %Y',
        year: '%Y'
      },
      offset: 10,
      labels: {
        align: 'center',
        style: {
          color: '#a8a8a8',
          'font-weight':  700
        },
        useHTML: true
      },
      tickColor: 'white',
      maxPadding: 0.04,
      minPadding: 0.04
    }
  }

  function y_axis_params (){
    return  {
      allowDecimals: false,
      gridLineColor: '#d6d6d6',
      offset: 7,
      labels: {
        style: {
          color: '#a8a8a8',
          'font-weight':  700
        },
        useHTML: true
      },
      title: {
        text: ""
      },
      min: 0,
      tickPixelInterval: 47
    }

  }

  function init(){
    initChart();
  }

  return {
    init: init
  };
}());

$(function(){
  Airbo.FinancialKpiChart.init();
});
