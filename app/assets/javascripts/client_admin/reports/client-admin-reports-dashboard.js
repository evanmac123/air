var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsDashboard = (function(){
  var reportSel = ".report-container";

  function activateReportModules() {
    $.each($(".report-module"), function(i, module) {
      activateReportModule($(module));
    });
  }

  function activateReportModule($module) {
    requestSubmoduleData($module);
    requestModuleCharts($module);
  }

  function requestSubmoduleData($module) {
    var submodules = $module.find(".reports-submodule");
    $.each(submodules, function(i, submodule) {
      Airbo.ClientAdminReportsDashboardSubmodules.buildSubmodule($(submodule));
    });
  }

  function requestModuleCharts($module) {
    var charts = $module.find(".chart-container");
    $.each(charts, function(i, chart) {
      Airbo.ClientAdminReportsDashboardCharts.buildChart($(chart));
    });
  }

  function reportDateChange() {
    $(".report-interval-change").on("click", function(e) {
      e.preventDefault();

      if ($(this).hasClass("tabs-component-active")) {
        return false;
      }

      Airbo.ClientAdminReportsUtils.switchActiveTab($(this));

      $(reportSel).data("startDate", $(this).data("startDate"));
      $(reportSel).data("endDate", $(this).data("endDate"));

      activateReportModules();
    });
  }

  function init() {
    $(".report-container").fadeIn();
    activateReportModules();
    reportDateChange();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".client_admin-reports")) {
    Airbo.ClientAdminReportsDashboard.init();
  }
});
