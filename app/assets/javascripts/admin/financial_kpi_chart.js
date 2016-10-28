var Airbo = window.Airbo || {};

Airbo.FinancialKpiChart = (function(){

  var totalCustomers = ".total-customers .header-number",
    totalBooked = ".total-booked .header-number",
    totalMrr = ".total-mrr .header-number",
    chartContainer = "#chart-container",
    chartData,
    tableData,
    dates, 
    kpiChart
  ;
  var tableTemplate=[
    "<table>",
    "<thead><tr><td>&nbsp;</td>",
    "{{#each headers}}",
    "<td>{{this}}</td>",
    "{{/each}}",
    "</tr></thead>",
    "<tbody>",
    "{{#each rows}}",
    "<tr>",
    "<th>{{label}}</th>",
    "{{#each values}}",
    "<td>{{this}}</td>",
    "{{/each}}",
    "</tr>",
    "{{/each}}",
    "</tbody></table>"
  ].join("");

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
        data: chartData
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
    prepareDataForChart(data.tableData);
    refreshChart();
    refreshTotals(data.totals);
    refreshTable(tableData)
    kpiChart.hideLoading();
  }

  function refreshTable(data){
    rebuildTable();
  }


  function refreshChart(){
    kpiChart.series[0].setData(chartData);
  }

  function refreshTotals(totals){
    [totalMrr, totalCustomers, totalBooked].forEach(function(kpi){
      var metric = $(kpi)
        , val = totals[metric.data("kpi")]
      ;
      metric.text(val.toLocaleString("en-US"));
    });
  }

  function submitFailure(){
    console.log("error occured"); 
  }

  function initForm(){
    $("#financials_filter").submit(function(event){
      event.preventDefault(); 
      kpiChart.showLoading();
      Airbo.AjaxResponseHandler.submit($(this), refresh, submitFailure);
    })
  }

  function initChartDataFromDataAttributes(){
    prepareDataForChart(chartContainer.data("plotdata"));
  }

 function prepareDataForChart(data){
   getDateSeries(data.weekending_date.values);
   chartData = dates.map(
     function(date,idx){ 
       return{
         x: date,
         y: data.starting_mrr.values[idx]
       }
     });

     tableData = { headers: converDates(), rows: getTableRows(data)};
 }

 function getTableRows(data){
   return Object.keys(data).map(function (kpi) { 
     if(kpi !== "weekending_date"){
       return data[kpi];
     }
   });
 }

 function converDates(){
   return dates.map(function(date){
     return (new Date(date)).toLocaleString("en-US", {year: "2-digit", month: "2-digit", day: "2-digit"});
   });
 }

 function getDateSeries(data){
   if(data !== null){
     dates = data.map(
       function(val,idx){ 
         return  Date.parse(val)
       });
   }else{
      alert("Something went wrong with this request. Please refresh and try again or change the date range")
   }
 }


 function rebuildTable(){
  
    var theTemplate = Handlebars.compile (tableTemplate);  
   $(".table-container").html(theTemplate (tableData));
 }


  function init(){
   initVars();
   initChartDataFromDataAttributes();
   initChart(chartContainer);
   initForm();
  }




  return {
    init: init
  };
}());

$(function(){
  if(Airbo.Utils.supportsFeatureByPresenceOfSelector(".financial-kpis-graph")){
    Airbo.FinancialKpiChart.init();
  }
});
