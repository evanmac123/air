var Airbo = window.Airbo ||{}

Airbo.Utils = Airbo.Utils || {}
Airbo.Utils.KpiReportDateFilter = (function(){
  var  builtinRangeSel =".builtin-date-range"
    , customRangeSel = ".custom-date-range"
    , builtinRange
    , customRange
  ;

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


  function initDateRangeFilters(){

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




  function init(){
    builtinRange =$(builtinRangeSel);
    customRange = $(customRangeSel); 
    initDateRangeFilters();
    initCustomDateDone();
  }

  return {
    init: init,
    adjustDateRanges: adjustDateRanges
  }

}());


$(function(){
  Airbo.Utils.KpiReportDateFilter.init();
})

