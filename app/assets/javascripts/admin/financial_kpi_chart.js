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
      setEndDateForRange();
      Airbo.AjaxResponseHandler.submit($(this), refreshWithHTML, submitFailure, "html");
    })
  }

  function startDateFromTimeStamp(ts){
    var start = Date.now() - (ts * 1000);
    return new Date(start); 
  }

  function setEndDateForRange(){
    var selected = $("#interval option:selected").val()
      , e
    ;

    if(selected === "monthly"){
      e = Airbo.Utils.Dates.lastDayOfMonth();
    }else if (selected=="weekly"){
      e = Airbo.Utils.Dates.lastDayOfWeek();
    }else{
      e = new Date();
    }

    $("input[name='edate']").val(extractDateStringFromISO(e));
  }


  function initDateFilters(){

    $("#date_range").change(function(event){
      var s;

      if($(this).val()==="-1"){
        customRange.show();
        builtinRange.hide();
      }else{
        s = startDateFromTimeStamp($(this).val());
        $("input[name='sdate']").val(extractDateStringFromISO(s));
      }
    });
  }

  function extractDateStringFromISO(d){
    return d.toISOString().split("T")[0]
  }

  function initCustomDateDone(){
    $("body").on("click", ".custom-date-done", function(e){
      var  range = $("#sdate").val() + " to " + $("#edate").val() ;
      e.preventDefault();
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
