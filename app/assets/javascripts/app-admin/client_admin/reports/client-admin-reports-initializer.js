var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsInitializer = (function() {
  function initReportSwitcher() {
    $(".js-report-switcher-tab").on("click", function(e) {
      e.preventDefault();

      var $reportTab = $(this);
      loadReport($reportTab);
      storeCurrentHash($reportTab);
    });

    if (this.location.hash === "") {
      this.location.hash = "#tab-tile-emails";
    }
  }

  function loadReport($reportTab) {
    $reportTab.siblings().removeClass("active");
    $reportTab.addClass("active");

    Airbo.ClientAdminReportsUtils.hideReports();

    $reportTabTarget = $($reportTab.data("target"));

    $reportTabTarget.fadeIn();
    reflowHighcharts();
  }

  function storeCurrentHash($tab) {
    if ($tab[0].attributes["data-status"] !== undefined) {
      var hash = "#tab-" + $tab[0].attributes["data-status"].nodeValue;
      this.location.hash = hash;
    }
  }

  function reflowHighcharts() {
    $.each($(".js-highcharts-chart"), function(i, chart) {
      $(chart)
        .highcharts()
        .reflow();
    });
  }

  function identifyAndSwitchTab() {
    var tabIdentifier = this.location.hash.split("#tab-");

    if (tabIdentifier.length > 1) {
      loadIdentifiedReportTab($("li[data-status='" + tabIdentifier[1] + "']"));
    } else {
      loadIdentifiedReportTab($("li[data-status='tile-emails']"));
    }
  }

  function loadIdentifiedReportTab($reportTab) {
    $reportTab.addClass("active");
    $reportTab.trigger("click");
    $(window).load(function() {
      loadReport($reportTab);
    });
  }

  function init() {
    identifyAndSwitchTab();
    initReportSwitcher();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".client_admin-reports")) {
    Airbo.ClientAdminReportsInitializer.init();
  }
});
