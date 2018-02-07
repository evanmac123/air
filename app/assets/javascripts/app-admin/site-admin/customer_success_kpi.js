var Airbo = window.Airbo || {};

Airbo.CustomerSuccessKpi = (function() {
  function refreshWithHTML(html) {
    $(".tabular-data").html(html);
  }
  function submitFailure() {
    console.log("error occured");
  }

  function initForm() {
    $(".report-filter").submit(function(event) {
      event.preventDefault();
      Airbo.Utils.KpiReportDateFilter.adjustDateRanges();
      Airbo.AjaxResponseHandler.submit(
        $(this),
        refreshWithHTML,
        submitFailure,
        "html"
      );
    });
  }

  function init() {
    Airbo.Utils.KpiReportDateFilter.init();
    initForm();
  }

  return {
    init: init
  };
})();
$(function() {
  if (
    Airbo.Utils.supportsFeatureByPresenceOfSelector(
      ".customer-success.kpi-dashboard"
    )
  ) {
    Airbo.CustomerSuccessKpi.init();
  }
});
