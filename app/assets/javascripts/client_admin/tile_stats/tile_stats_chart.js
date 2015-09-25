var Airbo = window.Airbo || {};

Airbo.TileStatsChart = (function(){
  // Selectors
  var
      actionInputSel    = "[name='tile_stats_chart_form[action_type]']",
      intervalInputSel  = "[name='tile_stats_chart_form[interval_type]']",
      valueInputSel     = "[name='tile_stats_chart_form[value_type]']",
      dateRangeInputSel = "[name='tile_stats_chart_form[date_range_type]']",
      dateStartSel      = "[name='tile_stats_chart_form[start_date]']",
      dateEndSel        = "[name='tile_stats_chart_form[end_date]']",
      changedFieldSel   = "[name='tile_stats_chart_form[changed_field]']",
      datesSelectionSel = ".dates_selection",
      downloadChartSel = "#download_chart",
      doneBtnSel        = datesSelectionSel + " a",
      formSel           = "#new_tile_stats_chart_form",
      formSendSel       = [
        actionInputSel,
        intervalInputSel,
        valueInputSel,
        dateRangeInputSel,
        dateStartSel,
        dateEndSel
      ].join(", ");

  // DOM elements
  var
      dateRangeBlock,
      datesSelection,
      datePickers,
      downloadChart,
      form;

  var eventsInitialized;

  function formResponse(){
    return function (data){
      if(data.success){
        $(".tile_chart_section").replaceWith(data.chart);
        initVars();
      }
    };
  }

  function submitForm(){
    form.ajaxSubmit({
      success: formResponse(),
      dataType: 'json'
    });
  }

  function initVars(){
    dateRangeBlock = $(".date_range_block");
    datesSelection = $(datesSelectionSel);
    dateRange = $(dateRangeInputSel);
    datePickers = $(dateStartSel + ", " + dateEndSel);
    changedFiled = $(changedFieldSel);
    form = $(formSel);
    downloadChart = $(downloadChartSel);

    datePickers.datepicker({
      showOtherMonths: true,
      selectOtherMonths: true,
      dateFormat: 'M d, yy',
      maxDate: 0
    });
  }

  function initEvents(){
    if(eventsInitialized){
      return;
    }else{
      eventsInitialized = true;
    }

    $(document).on("change", formSendSel, function(){
      input = $(this);
      if(input.val() == "pick_a_date_range"){
        dateRangeBlock.hide();
        datesSelection.show();
        datePickers.first().datepicker("show");
      }else if(input == dateRange && input.find("option").eq(0).attr("selected")){
        return;
      }else{
        changedFiled.val(input.attr("name").match(/\[(.*)\]/)[1]);
        submitForm();
      }
    });
    $(document).on("click", doneBtnSel, function(e){
      e.preventDefault();

      dateRangeBlock.show();
      datesSelection.hide();

      dateRange.val(0);
      dateRange.trigger("change", true); // to update custom select
    });
    $(document).on("change", downloadChartSel, function(e){
      text = downloadChart.val();

      if(text == "Download") return;
      $("#exportButton").click();
      $( ".highcharts-container div:contains(" + "Download " + text + ")" ).last().click();

      downloadChart.find('option').eq(0).prop('selected', true);
      downloadChart.trigger("change", true); // to update custom select
    });
  }

  function init(){
    initVars();
    initEvents();

    setTimeout(submitForm, 100);
  }
  return {
    init: init
  };
}());

$(function(){
  if (Airbo.Utils.isAtPage(Airbo.Utils.Pages.TILE_STATS_CHART)) {
    Airbo.TileStatsChart.init();
  }
});
