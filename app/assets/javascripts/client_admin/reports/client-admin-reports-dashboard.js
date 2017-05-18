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
      Airbo.ClientAdminReportsDashboardSubmodules.buildSubmodule($(submodule), $module);
    });
  }

  function requestModuleCharts($module) {
    var charts = $module.find(".chart-container");
    $.each(charts, function(i, chart) {
      Airbo.ClientAdminReportsDashboardCharts.buildChart($(chart), $module);
    });
  }

  function moduleDateChange() {
    $(".module-interval-change").on("click", function(e) {
      e.preventDefault();

      if ($(this).hasClass("selected")) {
        return false;
      }

      var moduleSel = $(this).data("moduleTarget");
      var $module = $(moduleSel);

      $module.data("startDate", $(this).data("startDate"));
      $module.data("endDate", $(this).data("endDate"));

      activateReportModule($module);
    });
  }

  function init() {
    $(".report-container").fadeIn();
    activateReportModules();
    moduleDateChange();
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
