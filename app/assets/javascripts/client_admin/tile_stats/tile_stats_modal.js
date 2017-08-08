var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function(){
  // Selectors
  var tileStatsLinkSel = ".tile_stats .stat_action";
  var modalId = "tile_stats_modal";
  var modalObj = Airbo.Utils.StandardModal();
  var chart;
  var grid;

  function renderReport() {
    return function (data) {
      $(".tile-stats-modal").data("tileStatsData", data);
      initModalEvents();
      fillAnalyticsTab();
      fillActivityTab();
      fillMessagesTab();
      reloadComponents();
      Airbo.TileStatsGrid.gridRequest($(".tile_grid_section").data("updateLink"));
    };
  }

  function initModalEvents() {
    $(".js-tile-stats-tab").on("click", function(e) {
      e.preventDefault();
      switchTabs($(this));
    });
  }

  function tileStatsData() {
    return $(".tile-stats-modal").data("tileStatsData");
  }

  function fillData() {

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

  function fillAnalyticsTab() {
    var template = HandlebarsTemplates["client-admin/tile-stats-modal/tileStatsAnalytics"](tileStatsData());
    $(".js-tile-stats-modal-tab-content.analytics").html(template);
  }

  function fillActivityTab() {
    var template = HandlebarsTemplates["client-admin/tile-stats-modal/tileStatsActivity"](tileStatsData());
    $(".js-tile-stats-modal-tab-content.activity").html(template);
  }

  function fillMessagesTab() {
    var template = HandlebarsTemplates["client-admin/tile-stats-modal/tileStatsMessages"](tileStatsData());
    $(".js-tile-stats-modal-tab-content.messages").html(template);
  }

  function reloadComponents() {
    // chart.init();
    grid.init();
  }

  function getTileStatsReport(path, tile) {
    $.ajax({
      url: path,
      success: renderReport(),
      dataType: "json"
    });
  }

  function initEvents() {
    $(document).on("click", tileStatsLinkSel, function(e) {
      e.preventDefault();
      var path = $(this).data("href");
      var tile = $(this).closest(".tile_container");
      openLoadingModal(tile);
      getTileStatsReport(path);
    });
  }

  function baseTemplate(data) {
    return HandlebarsTemplates["client-admin/tile-stats-modal/tileStatsBase"](data);
  }


  function openLoadingModal(tile) {
    var headline = tile.data("headline");
    var template = Airbo.TileStatsModal.baseTemplate({ headline: headline });
    modalObj.setContent(template);
    modalObj.open();
  }

  function initVars(){
    chart = Airbo.TileStatsChart;
    grid = Airbo.TileStatsGrid;
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      modalClass: "js-tile-stats-modal tile-stats-modal",
      useAjaxModal: true
    });
  }

  function init(){
    initModalObj();
    initVars();
    initEvents();
  }

  return {
    init: init,
    baseTemplate: baseTemplate
  };
}());

$(function(){
  var mainTilePage = $(".client_admin-tiles.client_admin-tiles-index.client_admin_main");
  var archivedTilePage = $(".client_admin-inactive_tiles.client_admin-inactive_tiles-index.client_admin_main");
  var reportsPage = $(".client_admin-reports");
  if( mainTilePage.length > 0 || archivedTilePage.length > 0 || reportsPage.length > 0) {
    Airbo.TileStatsModal.init();
  }
});
