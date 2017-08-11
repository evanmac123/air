var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function(){
  var tileStatsLinkSel = ".js-open-tile-stats-modal";
  var modalId = "tile_stats_modal";
  var modalObj = Airbo.Utils.StandardModal();

  function renderReport() {
    return function (data) {
      initModal(data);
      loadChartAndGrid(data);
    };
  }

  function initModal(data) {
    $(".card-title").text(data.headline);
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
    fillMessagesTab();
  }

  function switchTabs($tab) {
    hideCurrentTab();
    showNewTab($tab);
  }

  function hideCurrentTab() {
    $(".js-tile-stats-tab").removeClass("active");
    $(".js-tile-stats-modal-tab-content").addClass("hidden");
  }

  function showNewTab($tab) {
    $tab.addClass("active");
    var $tabNode = getTabNode($tab);
    $tabNode.removeClass("hidden");
    Airbo.Utils.DropdownButtonComponent.reflow();
  }

  function getTabNode($tab) {
    return $(".js-tile-stats-modal-tab-content." + $tab.data("tabContent"));
  }

  function setTemplate(template) {
    return HandlebarsTemplates["client-admin/tile-stats-modal/" + template](tileStatsData());
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

  function fillMessagesTab() {
    var template = setTemplate("tileStatsMessages");
    $(".js-tile-stats-modal-tab-content.messages").html(template);
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
      useAjaxModal: true
    });
  }

  function initEvents() {
    $(document).on("click", tileStatsLinkSel, function(e) {
      e.preventDefault();
      var path = $(this).data("href");
      var tileId = $(this).data("tileId");
      openModal(tileId);
      getTileStatsReport(path);
    });
  }

  function openModal(tileId) {
    var template = baseTemplate({ tileId: tileId });
    modalObj.setContent(template);
    modalObj.open();
  }

  function baseTemplate(data) {
    return HandlebarsTemplates["client-admin/tile-stats-modal/tileStatsBase"](data);
  }

  function getTileStatsReport(path, tile) {
    $.ajax({
      url: path,
      success: renderReport(),
      dataType: "json"
    });
  }

  function init(){
    initModalObj();
    initEvents();
  }

  return {
    init: init
  };
}());

$(function() {
  if (Airbo.Utils.nodePresent(".js-open-tile-stats-modal") || Airbo.Utils.nodePresent(".client_admin-reports")) {
    Airbo.TileStatsModal.init();
  }
});
