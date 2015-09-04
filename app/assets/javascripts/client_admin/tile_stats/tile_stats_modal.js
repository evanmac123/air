var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function(){
  // Selectors
  var tileStatsLinkSel = ".tile_stats a",
      modalSel = "#tile_stats_modal",
      modalContentSel = modalSel + " #modal_content";
  // DOM elements
  var modal,
      modalContent;
  //

  function ajaxResponse(){
    return function (data){
      modalContent.html(data.page);
      initComponents();
      modal.foundation("reveal", "open");
    };
  }

  function initComponents() {
    Airbo.TileStatsChart.init();
    Airbo.TileStatsGrid.init();
    Airbo.SurveyTable.init();
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
