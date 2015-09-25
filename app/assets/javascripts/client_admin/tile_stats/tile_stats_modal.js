var Airbo = window.Airbo || {};

Airbo.TileStatsModal = (function(){
  // Selectors
  var tileStatsLinkSel = ".tile_stats .stat_action",
      modalSel = "#tile_stats_modal",
      modalContentSel = modalSel + " #modal_content",
      modalBgSel = '.reveal-modal-bg';
  // DOM elements
  var modal,
      modalContent,
      chart,
      grid;

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
  }

  function getPage(link) {
    $.ajax({
      url: link,
      success: ajaxResponse(),
      dataType: "json"
    });
  }

  function modalOpenClose() {
    $(document).on('open', modalSel, function(){
      $("body").addClass('overflow_hidden');
    });

    $(document).on('closed', modalSel, function(){
      $("body").removeClass('overflow_hidden');
    });
  }

  function initEvents(){
    $(document).on("click", tileStatsLinkSel, function(e) {
      e.preventDefault();
      getPage( $(this).data("href") );
    });
    modalOpenClose();
  }

  function initVars(){
    modal = $(modalSel);
    modalContent = $(modalContentSel);
    chart = Airbo.TileStatsChart;
    grid = Airbo.TileStatsGrid;
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
