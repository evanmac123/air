var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function() {
  var tileStatsLinkSel = ".js-open-tile-stats-modal";
  var modalId = "tile_stats_modal";
  var modalObj = Airbo.Utils.StandardModal();

  function renderReport() {
    return function(data) {
      initModal(data);
      loadChartAndGrid(data);
      Airbo.TileStatsMessageEditor.init();
      Airbo.TileStatsMessageSender.init();
    };
  }

  function initModal(data) {
    $(".js-tile-stats-modal-title").text(data.headline);
    $(".tile-stats-modal").data("tileStatsData", data);

    $(".js-tile-stats-tab").on("click", function(e) {
      e.preventDefault();
      switchTabs($(this));
    });

    fillModalTabs();
  }

  function fillModalTabs() {
    fillAnalyticsTab();
    fillActivityTab();
    fillMessageTab();
    fillSentTab();
  }

  function switchTabs($tab) {
    Airbo.TileStatsPings.ping({ action: "Changed Tab", tab: $tab.text() });

    Airbo.SubComponentFlash.destroy();
    hideCurrentTab();
    showNewTab($tab);
  }

  function hideCurrentTab() {
    $(".js-tile-stats-tab").removeClass("active");
    $(".js-tile-stats-modal-tab-content").addClass("hidden");
  }

  function showNewTab($tab) {
    var $tabNode = getTabNode($tab);
    $tab.addClass("active");
    $tabNode.removeClass("hidden");
    $(".grid_types select").niceSelect();
  }

  function getTabNode($tab) {
    return $(".js-tile-stats-modal-tab-content." + $tab.data("tabContent"));
  }

  function setTemplate(template) {
    return HandlebarsTemplates["client-admin/tile-stats-modal/" + template](
      tileStatsData()
    );
  }

  function tileStatsData() {
    return $(".tile-stats-modal").data("tileStatsData");
  }

  function fillAnalyticsTab() {
    var template = setTemplate("tileStatsAnalytics");
    $(".js-tile-stats-modal-tab-content.analytics").html(template);
  }

  function fillActivityTab() {
    var template = setTemplate("tileStatsActivity");
    $(".js-tile-stats-modal-tab-content.activity").html(template);
  }

  function fillMessageTab() {
    var template = setTemplate("tileStatsMessage");
    $(".js-tile-stats-modal-tab-content.message").html(template);
  }

  function fillSentTab() {
    var template = setTemplate("tileStatsSent");
    $(".js-tile-stats-modal-tab-content.sent").html(template);
  }

  function loadChartAndGrid(data) {
    Airbo.TileStatsChart.init(data);
    Airbo.TileStatsGrid.init();
    Airbo.TileStatsGrid.gridRequest($(".tile_grid_section").data("updateLink"));
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      modalClass: "js-tile-stats-modal tile-stats-modal",
      useAjaxModal: true,
      onClosedEvent: modalClosedEvents
    });
  }

  function modalClosedEvents() {
    Airbo.GridUpdatesChecker.stopChecker();
  }

  function initEvents() {
    $(document).on("click", tileStatsLinkSel, function(e) {
      var path = $(this).data("href");
      var tileId = $(this).data("tileId");
      e.preventDefault();

      openModal(tileId);
      getTileStatsReport(path);
    });

    $(document).on("click", ".js-tile-stats-download-report", function() {
      Airbo.TileStatsPings.ping({
        action: "Download Stats Report",
        reportPath: $(this).attr("href")
      });
    });
  }

  function openModal(tileId) {
    var template = baseTemplate({ tileId: tileId });
    Airbo.TileStatsPings.ping({ action: "Opened Stats Modal", tileId: tileId });

    modalObj.setContent(template);
    modalObj.open();
  }

  function baseTemplate(data) {
    return HandlebarsTemplates["client-admin/tile-stats-modal/tileStatsBase"](
      data
    );
  }

  function getTileStatsReport(path, tile) {
    $.ajax({
      url: path,
      success: renderReport(),
      dataType: "json"
    });
  }

  function init() {
    initModalObj();
    initEvents();
  }

  return {
    init: init
  };
})();

$(function() {
  if (
    Airbo.Utils.nodePresent(".js-open-tile-stats-modal") ||
    Airbo.Utils.nodePresent(".client_admin-reports")
  ) {
    Airbo.TileStatsModal.init();
  }
});
