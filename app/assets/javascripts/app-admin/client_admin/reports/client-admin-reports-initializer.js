var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsInitializer = (function(){

  function initReportSwitcher() {
    $(".js-report-switcher-tab").on("click", function(e) {
      e.preventDefault();

      var $reportTab = $(this);

      $reportTab.siblings().removeClass("active");
      $reportTab.addClass("active");

      Airbo.ClientAdminReportsUtils.hideReports();

      $reportTabTarget = $($reportTab.data("target"));

      $reportTabTarget.fadeIn();
      reflowHighcharts();
    });
  }

  function reflowHighcharts() {
    $.each($(".js-highcharts-chart"), function(i, chart) {
      $(chart).highcharts().reflow();
    });
  }

  function init() {
    initReportSwitcher();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".client_admin-reports")) {
    Airbo.ClientAdminReportsInitializer.init();
  }
});
