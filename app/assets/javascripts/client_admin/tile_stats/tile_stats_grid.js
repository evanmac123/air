var Airbo = window.Airbo || {};

Airbo.TileStatsGrid = (function(){
  // Selectros
  var tileGridSectionSel = ".tile_grid_section",
      linkInGridSel = tileGridSectionSel + " a:not(.download_as_csv)",
      gridLinkSel = ".grid_types a",
      currentGridLinkSel = gridLinkSel + ".current",
      answerCellSel = tileGridSectionSel + " tbody .answer_column",
      surveyTableSel = "#survey_table";
  // JQuery Objects
  var tileGridSection,
      surveyTable;

  var updateLink,
      updatesChecker,
      eventsInitialized;

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

  function gridRequest(url) {
    $.ajax({
      url: url,
      success: ajaxResponse(),
      dataType: "json"
    });
    updatesChecker.stopChecker();
  }

  function updateGrid(link) {
    gridRequest( updateLink + "?" + getLinkParams(link) );
  }

  function markAnswerInSurveyTable(answer){
    selectedRow = surveyTable.find("td:contains('" + answer + "')").closest('tr');
    prevRow = selectedRow.prev();
    if( prevRow.length == 0 ){
      prevRow = surveyTable.find('thead tr');
    }
    selectedRow.addClass("selected");
    prevRow.addClass("selected");
  }

  function unmarkAnswerInSurveyTable() {
    surveyTable.find('tr.selected').removeClass('selected');
  }

  function filterByAnswer(answer){
    if(answer == "-") return;
    markAnswerInSurveyTable(answer);
    gridRequest( updateLink + "?answer_filter=" + answer);
  }

  function initVars(){
    tileGridSection = $(tileGridSectionSel);
    updateLink = tileGridSection.data("update-link");
    surveyTable = $(surveyTableSel);

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

    $(document).on("click", gridLinkSel, function(){
      unmarkAnswerInSurveyTable();
    });

    $(document).on("click", answerCellSel, function(e){
      e.preventDefault();
      filterByAnswer( $(this).text() );
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
