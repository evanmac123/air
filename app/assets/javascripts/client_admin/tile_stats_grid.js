var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function(){
  // Selectros
  var
      gridSel = "#tile_stats_grid",
      linkInGrid = gridSel + " a",
      updateGridSel = "#update_grid";

  var updateLink;

  function ajaxResponse(){
    return function (data){
      if(data.success){
        $(gridSel).replaceWith(data.grid);
      }
    };
  }

  function initVars(){
    updateLink = $(updateGridSel).attr("href");
  }
  function initEvents(){
    $(document).on("click", linkInGrid, function(e){
      e.preventDefault();
      linkParams = $(this).attr("href");
      $.ajax({
        url: updateLink + linkParams,
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
