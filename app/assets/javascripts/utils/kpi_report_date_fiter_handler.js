var Airbo = window.Airbo ||{}

Airbo.Utils = Airbo.Utils || {}
Airbo.Utils.KpiReportDateFilter = (function(){
  var  builtinRangeSel =".builtin-date-range"
    , customRangeSel = ".custom-date-range"
    , builtinRange
    , customRange
  ;

  function adjustDateRanges(){
    var interval = $("#interval option:selected").val()
      , range = $("#date_range option:selected").val()
    ;
    if(range !=="-1"){
      setStartDateForRange(interval, range);
      setEndDateForRange(interval,range);
    }
  }

  function startDateFromTimeStamp(ts){
    var start = Date.now() - (ts * 1000);
    return new Date(start);
  }

  function setEndDateForRange(interval, range){
    var edate;

      if(interval === "monthly"){
        edate = Airbo.Utils.Dates.lastDayOfMonth();
      }else {
        edate = Airbo.Utils.Dates.lastDayOfWeek();
      }
      $("input[name='edate']").val(extractDateStringFromISO(edate));
  }

  function setStartDateForRange(interval, range){
    var sdate;

      sdate = startDateFromTimeStamp(range);
      if(interval === "monthly"){
        sdate = Airbo.Utils.Dates.firstDayOfMonth(sdate);
      }else{
        sdate = Airbo.Utils.Dates.firstDayOfWeek(sdate);
      }
      $("input[name='sdate']").val(extractDateStringFromISO(sdate));
  }




  function extractDateStringFromISO(date){
    return date.toISOString().split("T")[0]
  }

  function initCustomDateDone(){
    $("body").on("click", ".custom-date-done", function(event){
      event.preventDefault();
      var sdatePicker= $("#sdate_picker")
        , edatePicker= $("#edate_picker")
        , range = sdatePicker.val() + " to " + edatePicker.val()
      ;
      $( '#sdate_picker' ).datepicker( "option", "altField", "#sdate" );
      $( '#edate_picker' ).datepicker( "option", "altField", "#edate" );



      customRange.hide();
      builtinRange.show();

        $(".button.submit").show();
      $("#date_range_chosen .chosen-single span").text(range);
      Airbo.PubSub.subscribe("report-date-form-submitted", function(){
        $("#date_range").val('').trigger("chosen:updated");
        $("#date_range_chosen .chosen-single span").text(range);
      });
    });
  }

  function setRange(range){
    $("#date_range_chosen .chosen-single span").text(range);
  }

  function initDateRangeFilters(){

    $("#date_range").change(function(event){
      var sdate;
      if($(this).val()==="-1"){
        customRange.show();
        builtinRange.hide();
        $(".button.submit").hide();
      }else{
        sdate = startDateFromTimeStamp($(this).val());
        $("input[name='sdate']").val(extractDateStringFromISO(sdate));
      }
    });
  }


  function initJQueryDatePicker(){
   $(".datepicker").datepicker({
      showOtherMonths: true,
      selectOtherMonths: true,
      dateFormat: 'M d, yy',
      altFormat: "yy-mm-dd",
      maxDate: 0,
      onClose: function(dateText, inst) {
        $(inst.input).removeClass("opened");
      }
    });
  }

  function init(){
    builtinRange =$(builtinRangeSel);
    customRange = $(customRangeSel);
    initJQueryDatePicker();
    initDateRangeFilters();
    initCustomDateDone();
  }

  return {
    init: init,
    adjustDateRanges: adjustDateRanges
  }

}());
