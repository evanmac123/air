var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function(){
  // Selectors
  var tileStatsLinkSel = ".tile_stats .stat_action"
    , modalId = "tile_stats_modal"
    , modalObj = Airbo.Utils.StandardModal()
    ;

  var chart
    , grid
    ;

  function ajaxResponse(){
    return function (data){
      modalObj.setContent(data.page);
      reloadComponents();
      modalObj.open();
    };
  }

  function reloadComponents() {
    chart.init();
    grid.init();
  }

  function getPage(link) {
    $.ajax({
      url: link,
      success: ajaxResponse(),
      dataType: "json"
    });
  }

  function initEvents(){
    $(document).on("click", tileStatsLinkSel, function(e) {
      e.preventDefault();
      getPage( $(this).data("href") );
    });
  }

  function initVars(){
    chart = Airbo.TileStatsChart;
    grid = Airbo.TileStatsGrid;
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true
    });
  }

  function init(){
    initModalObj();
    initVars();
    initEvents();
  }
  return {
    init: init
  };
}());

$(function(){
  var mainTilePage = $(".client_admin-tiles.client_admin-tiles-index.client_admin_main");
  var archivedTilePage = $(".client_admin-inactive_tiles.client_admin-inactive_tiles-index.client_admin_main");
  if( mainTilePage.length > 0 || archivedTilePage.length > 0){
    Airbo.TileStatsModal.init();
  }
});
