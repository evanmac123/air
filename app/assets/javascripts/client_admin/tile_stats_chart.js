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
      form;

  function formResponse(){
    return function (data){
      if(data.success){
        // console.log(data.chart);
        $(".tile_chart_section").replaceWith(data.chart);
        initVars();
      }
    };
  }

  function submitForm(){
    // form.submit();
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

    datePickers.datepicker();
  }

  function initEvents(){
    $(document).on("change", formSendSel, function(){
      input = $(this);
      if(input.val() == "pick_a_date_range"){
        dateRangeBlock.hide();
        datesSelection.show();
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
  }

  function init(){
    initVars();
    initEvents();
  }
  return {
    init: init
  };
}());

$(function(){
  if (Airbo.Utils.isAtPage(Airbo.Utils.Pages.TILE_STATS_CHART)) {
    Airbo.TileStatsChart.init();
  }
})
