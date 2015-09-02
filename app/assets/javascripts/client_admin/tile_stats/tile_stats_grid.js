var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function(){
  // Selectros
  var tileGridSectionSel = ".tile_grid_section",
      linkInGridSel = tileGridSectionSel + " a:not(.download_as_csv)",
      currentGridLinkSel = ".grid_types a.current";
  // JQuery Objects
  var tileGridSection;

  var updateLink,
      currentGridType,
      updatesChecker;

  function ajaxResponse(){
    return function (data){
      if(data.success){
        tileGridSection.replaceWith(data.grid);
        reInit();
      }
    };
  }

  function getLinkParams(link) {
    return link.attr("href").split('?')[1];
  }

  function updateGridType(link) {
    gridType = link.data("grid-type");
    if( gridType ){
      currentGridType = gridType;
    }
  }

  function updateGrid(link) {
    updateGridType(link);
    $.ajax({
      url: updateLink + "?" + getLinkParams(link),
      data: {grid_type: currentGridType},
      success: ajaxResponse(),
      dataType: "json"
    });
    updatesChecker.stopChecker();
  }

  function reInit() {
    initVars();
    updatesChecker.reStart();
  }

  function initVars(){
    tileGridSection = $(tileGridSectionSel);
    updateLink = tileGridSection.data("update-link");
    updateGridType( $(currentGridLinkSel) );
  }

  function initEvents(){
    $(document).on("click", linkInGridSel, function(e){
      e.preventDefault();
      updateGrid( $(this) );
    });
  }

  function init(){
    initVars();
    initEvents();
    updatesChecker = Airbo.GridUpdatesChecker.init();
    updatesChecker.start();
  }

  return {
    init: init
  };
}());

$(function(){
  if (Airbo.Utils.isAtPage(Airbo.Utils.Pages.TILE_STATS_GRID)) {
    Airbo.TileStatsGrid.init();
  }
});
