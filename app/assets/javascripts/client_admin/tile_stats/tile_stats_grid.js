var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function(){
  // Selectros
  var tileGridSectionSel = ".tile_grid_section",
      linkInGridSel = tileGridSectionSel + " a:not(.download_as_csv)",
      currentGridLinkSel = ".grid_types a.current",
      answerCellSel = tileGridSectionSel + " .answer_column";
  // JQuery Objects
  var tileGridSection;

  var updateLink,
      //currentGridType,
      updatesChecker,
      eventsInitialized,
      answerFilter;

  function ajaxResponse(){
    return function (data){
      if(data.success){
        tileGridSection.replaceWith(data.grid);
        initVars();
      }
    };
  }

  function getLinkParams(link) {
    return link.attr("href").split('?')[1] || "";
  }

  // function updateGridType(link) {
  //   gridType = link.data("grid-type");
  //   if( gridType ){
  //     currentGridType = gridType;
  //     answerFilter = "";
  //   }
  // }

  function gridRequest(url) {
    $.ajax({
      url: url,
      data: {
        //grid_type: currentGridType,
        answer_filter: answerFilter
      },
      success: ajaxResponse(),
      dataType: "json"
    });
    updatesChecker.stopChecker();
  }

  function updateGrid(link) {
    // updateGridType(link);
    gridRequest( updateLink + "?" + getLinkParams(link) );
  }

  function filterByAnswer(answer){
    //if(answer == "-") return;
    answerFilter = answer;
    gridRequest( updateLink );
  }

  function initVars(){
    tileGridSection = $(tileGridSectionSel);
    updateLink = tileGridSection.data("update-link");
    // updateGridType( $(currentGridLinkSel) );

    if(updatesChecker){
      updatesChecker.reStart();
    } else {
      updatesChecker = Airbo.GridUpdatesChecker.init();
      updatesChecker.start();
    }
  }

  function initEvents(){
    if(eventsInitialized){
      return;
    }else{
      eventsInitialized = true;
    }

    $(document).on("click", linkInGridSel, function(e){
      e.preventDefault();
      updateGrid( $(this) );
    });

    $(document).on("click", answerCellSel, function(e){
      e.preventDefault();
      filterByAnswer( $(this).text() );
    });
  }

  function init(){
    answerFilter = "";
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
