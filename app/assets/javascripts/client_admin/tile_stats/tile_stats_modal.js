var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function(){
  // Selectors
  var tileStatsLinkSel = ".tile_stats a",
      modalSel = "#tile_stats_modal",
      modalContentSel = modalSel + " #modal_content";
  // DOM elements
  var modal,
      modalContent,
      chart,
      grid,
      surveyTable;
  //

  function ajaxResponse(){
    return function (data){
      modalContent.html(data.page);
      reloadComponents();
      modal.foundation("reveal", "open");
    };
  }

  function reloadComponents() {
    chart.init();
    grid.init();
    surveyTable.init();
  }

  function getPage(link) {
    $.ajax({
      url: link.attr("href"),
      success: ajaxResponse(),
      dataType: "json"
    });
  }

  function initEvents(){
    $(document).on("click", tileStatsLinkSel, function(e) {
      e.preventDefault();
      getPage( $(this) );
    });
  }

  function initVars(){
    modal = $(modalSel);
    modalContent = $(modalContentSel);
    chart = Airbo.TileStatsChart;
    grid = Airbo.TileStatsGrid;
    surveyTable = Airbo.SurveyTable;
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
  if( $(".client_admin-tiles.client_admin-tiles-index.client_admin_main").length > 0 ){
    Airbo.TileStatsModal.init();
  }
});
