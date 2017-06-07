var Airbo = window.Airbo || {};

Airbo.ClientAdminTileEmailReports = (function(){
  var reportSelector = ".js-tile-email-report-module";
  var nextTileEmailReportSelector = ".js-next-tile-email-report";
  var $reportContainer;
  var $reportModulesContainer;
  var INITIAL_REPORT_LIMIT = 2;
  var INITIAL_REPORT_PAGE = 1;

  function loadReports(successCallback, failCallback) {
    var reportLimit = getReportLimit();
    var reportPage = getReportPage();

    $.ajax({
      url: $reportContainer.data("path"),
      type: "GET",
      data: { limit: reportLimit, page: reportPage},
      dataType: "json",
      success: function(response, status, xhr) {
        successCallback(response);
        manageNextReportButton(response);
      },
      fail: function(response, status, xhr) {
        failCallback(response);
      }
    });
  }

  function bindLoadMore() {
    $(nextTileEmailReportSelector).on("click", function(e) {
      e.preventDefault();
      var $button = $(this);
      $button.text("");
      $button.addClass("with_spinner");

      loadReports(loadSuccess);
    });
  }

  function manageNextReportButton(response) {
    var lastPage = response.data.lastPage;
    var $nextReportButton = $(nextTileEmailReportSelector);

    if (lastPage) {
      $nextReportButton.remove();
    } else {
      var reportCount = $(reportSelector).length;
      var nextPage = reportCount + 1;
      $reportContainer.data("nextPage", nextPage);
      $reportContainer.data("nextPageLimit", 1);

      $nextReportButton.show();
    }
  }

  function getReportLimit() {
    return $reportContainer.data("nextPageLimit") || INITIAL_REPORT_LIMIT;
  }

  function getReportPage() {
    return $reportContainer.data("nextPage") || INITIAL_REPORT_PAGE;
  }

  function buildReport(report) {
    reportTemplate = HandlebarsTemplates.tileEmailReportTemplate(report);
    $reportModulesContainer.append(reportTemplate);
  }

  function buildInitialReports() {
    loadingTemplate = HandlebarsTemplates.cardLoadingTemplate();
    $reportModulesContainer.append(loadingTemplate);

    loadReports(initialLoadSuccess);
  }

  function loadSuccess(response) {
    resolveButton();

    var reports = response.data.reports;
    addReportsToPage(reports);
    bindReports();

    $(reportSelector).fadeIn();
  }

  function resolveButton() {
    var $button = $(".js-next-tile-email-report");
    $button.removeClass("with_spinner");
    $button.text("Load More");
  }

  function initialLoadSuccess(response) {
    var reports = response.data.reports;

    if (reports.length > 0) {
      addReportsToPage(reports);
      bindReports();
    } else {
      addNoDataReport();
    }

    $(".js-card-loading-template").remove();
    $(reportSelector).fadeIn();
  }

  function addNoDataReport() {
    var options = getNoDataOptions();

    reportTemplate = HandlebarsTemplates.noDataCardTemplate(options);
    $reportModulesContainer.append(reportTemplate);
  }

  function getNoDataOptions() {
    var tilesToBeSent = $(".js-sidenav-share-tab").data("tilesToBeSent");
    if (tilesToBeSent > 0) {
      var sharePath = $(".js-sidenav-share-tab a").attr("href");
      return {
        message: "Send a Tile Email to use these reports.",
        linkText: "See how",
        path: sharePath
      };
    } else {
      var editPath = $(".js-sidenav-edit-tab a").attr("href");
      return {
        message: "Post some Tiles and send a Tile Email to use these reports.",
        linkText: "Post Tiles",
        path: editPath
      };
    }
  }

  function toggleTileSection($expandButton) {
    var $tileData = $($expandButton.data("target"));

    $tileData.toggle();
    toggleExpandButton($expandButton, $tileData);
  }

  function bindReports() {
    bindTileDataToggle();
  }

  function bindTileDataToggle() {
    var $tileDataToggle = $(".js-expand-tile-data-button");
    $tileDataToggle.unbind();

    $tileDataToggle.on("click", function(e) {
      e.preventDefault();
      toggleTileSection($(this));
    });
  }

  function toggleExpandButton($expandButton, $tileData) {
    $expandButton.removeClass("expand-icon collapse-icon");

    if ($tileData.is(":visible")) {
      $expandButton.addClass("collapse-icon");
      $expandButton.text("Hide");
    } else {
      $expandButton.addClass("expand-icon");
      $expandButton.text("Expand");
    }
  }

  function addReportsToPage(reports) {
    reports.forEach(function(report) {
      buildReport(report);
    });
  }

  function init() {
    $reportContainer = $(".js-tile-emails-report-container");
    $reportModulesContainer = $(".js-tile-emails-report-modules-container");
    buildInitialReports();
    bindLoadMore();
  }

  return {
    init: init,
    reportContainer: $reportContainer
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".client_admin-reports")) {
    Airbo.ClientAdminTileEmailReports.init();
  }
});
