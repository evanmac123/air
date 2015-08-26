var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function(){
  // Selectros
  var
      gridSel = "#tile_stats_grid",
      linkInGridSel = gridSel + " a",
      tileGridSectionSel = ".tile_grid_section";

  var updateLink,
      tileGridSection,
      gridType = "all";

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
  }
  function initEvents(){
    $(document).on("click", linkInGridSel, function(e){
      e.preventDefault();
      linkParams = $(this).attr("href").split('?')[1];
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
