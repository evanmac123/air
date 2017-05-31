var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsInitializer = (function(){

  function initReportSwitcher() {
    $(".js-report-switcher-tab").on("click", function(e) {
      e.preventDefault();

      var $reportTab = $(this);

      Airbo.ClientAdminReportsUtils.switchActiveTab($reportTab);
      Airbo.ClientAdminReportsUtils.hideReports();

      $($reportTab.data("target")).fadeIn();
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
