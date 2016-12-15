var Airbo = window.Airbo || {};

Airbo.FinancialKpiChart = (function(){

  var chartData
    , tableData
    , dates 
    , kpiChart
    , chartContainer = "#chart-container"
    , builtinRangeSel =".builtin-date-range"
    , customRangeSel = ".custom-date-range"
    , builtinRange
    , customRange
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
      series: [{
        name: 'MRR',
        data: chartData,
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

    builtinRange =$(builtinRangeSel);
    customRange = $(customRangeSel); 

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
    Airbo.Utils.StickyTable.init();
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
    kpiChart.series[0].setData(chartData);
  }




  function initChartDataFromDataAttributes(){
    prepareDataForChart($(".chart-data").data("plotdata"));
  }

  function prepareDataForChart(data){
    getDateSeries(data.from_date.values);
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


  function init(){
    initVars();
    initChartDataFromDataAttributes();
    initChart(chartContainer);
    initDateFilters();
    initForm();
    initCustomDateDone();
  }

  function submitFailure(){
    console.log("error occured"); 
  }

  function initForm(){
    $("#financials-filter .report-filter").submit(function(event){
      event.preventDefault(); 
      kpiChart.showLoading();
      adjustDateRanges();
      Airbo.AjaxResponseHandler.submit($(this), refreshWithHTML, submitFailure, "html");
    })
  }

  function adjustDateRanges(){
    setStartDateForRange();
    setEndDateForRange();
  }

  function startDateFromTimeStamp(ts){
    var start = Date.now() - (ts * 1000);
    return new Date(start); 
  }

  function setEndDateForRange(){
    var selected = $("#interval option:selected").val()
      , edate
    ;

    if(selected === "monthly"){
      edate = Airbo.Utils.Dates.lastDayOfMonth();
    }else {
      edate = Airbo.Utils.Dates.lastDayOfWeek();
    }

    $("input[name='edate']").val(extractDateStringFromISO(edate));
  }

  function setStartDateForRange(){
    var interval = $("#interval option:selected").val()
      , range = $("#date_range option:selected").val()
      , sdate
    ;
 
    debugger
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


  function initDateFilters(){

    $("#date_range").change(function(event){
      var sdate;
      if($(this).val()==="-1"){
        customRange.show();
        builtinRange.hide();
      }else{
        sdate = startDateFromTimeStamp($(this).val());
        $("input[name='sdate']").val(extractDateStringFromISO(sdate));
      }
    });
  }

  function extractDateStringFromISO(date){
    return date.toISOString().split("T")[0]
  }

  function initCustomDateDone(){
    $("body").on("click", ".custom-date-done", function(event){
      var  range = $("#sdate").val() + " to " + $("#edate").val() ;
      event.preventDefault();
      customRange.hide();
      builtinRange.show();

      $(".date_range_custom_drop a.current").text(range);
    });
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
