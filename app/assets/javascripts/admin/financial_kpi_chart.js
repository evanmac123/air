var Airbo = window.Airbo || {};

Airbo.FinancialKpiChart = (function(){

  var chartData
    , tableData
    , dates 
    , kpiChart
    , chartContainer = "#chart-container"
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
      credits: {
        enabled: false
      },
      chart: {
        type: 'line'
      },
      title: {
        text: ''
      },
      xAxis: x_axis_params() ,
      yAxis: y_axis_params(),
      series: [chartData]
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
    chartContainer = $(chartContainer);
  }

  function refreshWithJson(data){
    prepareDataForChart(data.tableData);
    refreshChart();
    kpiChart.hideLoading();

    refreshTable(tableData)
  }

  function refreshWithHTML(html){
    $(".tabular-data").html(html);
    Airbo.Utils.StickyTable.reflow();

    if ($(".no-chart-data").length === 0){
      initChartDataFromDataAttributes();
      refreshChart();
    }else{
      kpiChart.series[0].remove(true);
    }

    kpiChart.hideLoading();
  }

  function refreshTable(data){
    rebuildTable();
  }


  function refreshChart(){
    kpiChart.series[0].setData(chartData.data);
  }


  function initChartDataFromDataAttributes(){
    prepareDataForChart($(".chart-data").data("plotdata"));
  }

  function prepareDataForChart(data){
    getDateSeries(data.from_date.values);
    plotdata = dates.map(
      function(date,idx){ 
        return{
          x: date,
          y: parseInt(data.starting_mrr.values[idx])
        }
      });

      chartData = {
        name: "MRR",
        data: plotdata
      };

      tableData = { headers: converDates(), rows: getTableRows(data)};
  }

  function getTableRows(data){
    return Object.keys(data).map(function (kpi) { 
      if(kpi !== "from_date"){
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



  function submitFailure(){
    console.log("error occured"); 
  }

  function initForm(){
    $(".report-filter").submit(function(event){
      event.preventDefault(); 
      kpiChart.showLoading();
      Airbo.Utils.KpiReportDateFilter.adjustDateRanges();
      Airbo.AjaxResponseHandler.submit($(this), refreshWithHTML, submitFailure, "html");
    })
  }


  function setStartDateForRange(){
    var interval = $("#interval option:selected").val()
      , range = $("#date_range option:selected").val()
      , sdate
    ;
 
    if(range !=="-1"){
      sdate = startDateFromTimeStamp(range);
      if(interval === "monthly"){
        sdate = Airbo.Utils.Dates.firstDayOfMonth(sdate);
      }else{
        sdate = Airbo.Utils.Dates.firstDayOfWeek(sdate);
      }
      $("input[name='sdate']").val(extractDateStringFromISO(sdate));
    }
  }



  function init(){
    initVars();
    initChartDataFromDataAttributes();
    initChart(chartContainer);
    initForm();

    Airbo.Utils.KpiReportDateFilter.init();
    Airbo.Utils.StickyTable.init();
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
