var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsUtils = (function() {
  function reportsBoardId() {
    var reportSel = ".js-reports-container";
    return $(reportSel).data("currentDemoId");
  }

  function hideReports() {
    $(".js-report-container").hide();
  }

  function switchActiveTab($node) {
    $node.siblings().removeClass("tabs-component-active");
    $node.addClass("tabs-component-active");
  }

  return {
    switchActiveTab: switchActiveTab,
    reportsBoardId: reportsBoardId,
    hideReports: hideReports
  };
})();
