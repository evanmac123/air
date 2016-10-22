var Airbo = window.Airbo || {};

Airbo.FinancialKpiChart = (function(){

  var totalCustomers = ".total-customers .header-number",
    totalBooked = ".total-booked .header-number",
    totalMrr = ".total-mrr .header-number",
    chartContainer = "#chart-container",
    kpiChart
  ;

  function initChart(container){
     kpiChart = Highcharts.chart(container.attr("id"), {
      chart: {
        type: 'line'
      },
      title: {
        text: 'Monthly Recuring Revenue'
      },
      xAxis: x_axis_params() ,
      yAxis: y_axis_params(),
      series: [{
        data: []//container.data("plotdata")
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

  function initVars(){
   totalMrr = $(totalMrr);
   totalCustomers = $(totalCustomers);
   totalBooked = $(totalBooked);
   chartContainer = $(chartContainer);
  }

  function refresh(data){
    refreshChart(data.plotData)
    refreshTotals(data.totals)
  }

  function refreshTable(tableData){

  }

  function refreshChart(plotData){
    kpiChart.series[0].setData(plotData);
  }

  function refreshTotals(totals){
    [totalMrr, totalCustomers, totalBooked].forEach(function(kpi){
      var metric = $(kpi);
      metric.text(totals[metric.data("kpi")]);
    })
  }

  function submitFailure(){
    console.log("error occured"); 
  }

  function initForm(){
    $("#financials_filter").submit(function(event){
      event.preventDefault(); 
      Airbo.AjaxResponseHandler.submit($(this), refresh, submitFailure);
    })
  }

  function init(){
    initVars();
    initChart(chartContainer);
    initForm();
  }

  var template=[
    "<table>",
    "<thead><tr><td>&nbsp;</td>",
    "{{each data.headers}}",
    "<td>{{this}}</td>",
    "{{/each}",
    "</tr></thead>",
    "<tbody>",
    "{{each dataRow}}",
    "<tr>",
    "<th>{{column.header}}</th>"
    "{{each column.values}}",
    "<td>{{this}}</td>"
    "{{/each}}",
    "</tr></tbody></table>"
  ];


  return {
    init: init
  };
}());

$(function(){
  Airbo.FinancialKpiChart.init();
});
