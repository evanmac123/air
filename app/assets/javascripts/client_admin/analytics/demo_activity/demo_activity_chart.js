var Airbo = window.Airbo || {};

Airbo.DemoActivityChart = (function(){
  // Selectors
  var
      actionInputSel    = "[name='demo_stats_chart_form[action_type]']",
      intervalInputSel  = "[name='demo_stats_chart_form[interval_type]']",
      valueInputSel     = "[name='demo_stats_chart_form[value_type]']",
      dateRangeInputSel = "[name='demo_stats_chart_form[date_range_type]']",
      dateStartSel      = "[name='demo_stats_chart_form[start_date]']",
      dateEndSel        = "[name='demo_stats_chart_form[end_date]']",
      changedFieldSel   = "[name='demo_stats_chart_form[changed_field]']",
      datesSelectionSel = ".dates_selection",
      downloadChartSel = "#download_chart",
      doneBtnSel        = datesSelectionSel + " a",
      formSel           = "#new_demo_stats_chart_form",
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
        $(".demo_chart_section").replaceWith(data.chart);
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
      maxDate: 0,
      onClose: function(dateText, inst) {
        $(inst.input).removeClass("opened");
      }
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
        datePickers.first().trigger("click").datepicker("show");
      }else if(input[0] == dateRange[0] && input.find("option").eq(0).attr("selected")){
        return;
      }else{
        changedFiled.val(input.attr("name").match(/\[(.*)\]/)[1]);
        submitForm();
      }
    });
    $(document).on("click", doneBtnSel, function(e){
      e.preventDefault();

      datesSelection.hide();
      dateRangeBlock.show();

      dateRange.val(0);
      dateRange.trigger("change", true); // to update custom select
    });

    $(document).on("change", downloadChartSel, function(e){
      text = downloadChart.val();

      if(text == "Download") return;
      $(".highcharts-button").click();
      $( ".highcharts-container div:contains(" + "Download " + text + ")" ).last().click();

      downloadChart.find('option').eq(0).prop('selected', true);
      downloadChart.trigger("change", true); // to update custom select
    });

    $(document).on("click", dateStartSel + ", " + dateEndSel, function(){
      $(this).addClass("opened");
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
  if (Airbo.Utils.supportsFeatureByPresenceOfSelector("#client-admin-demo-analytics")) {
    Airbo.DemoActivityChart.init();
  }
});
