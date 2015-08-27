var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function(){
  // Selectros
  var
      tileGridSectionSel = ".tile_grid_section",
      linkInGridSel = tileGridSectionSel + " a",
      currentGridLinkSel = ".grid_types a.current";

  var updateLink,
      tileGridSection,
      gridType;

  function ajaxResponse(){
    return function (data){
      if(data.success){
        tileGridSection.replaceWith(data.grid);
        initVars();
      }
    };
  }

  function initVars(){
    tileGridSection = $(tileGridSectionSel);
    updateLink = tileGridSection.data("update-link");
    gridType = $("currentGridLinkSel").data("grid-type");
  }
  function initEvents(){
    $(document).on("click", linkInGridSel, function(e){
      if( $(this).hasClass("download_as_csv") ) return;
      e.preventDefault();
      linkParams = $(this).attr("href").split('?')[1];
      if( $(this).data("grid-type") ){
        gridType = $(this).data("grid-type");
      }
      $.ajax({
        url: updateLink + "?" + linkParams,
        data: {grid_type: gridType},
        success: ajaxResponse(),
        dataType: "json"
      });
    });
  }
  function init(){
    initVars();
    initEvents();
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
