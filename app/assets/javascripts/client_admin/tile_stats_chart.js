var Airbo = window.Airbo || {};

Airbo.TileStatsChart = (function(){

  function init(){
    $('#tile_stats_chart_form_start_date, #tile_stats_chart_form_end_date').datepicker();
    // $("#tile_chart").ready(function(){
    //   $(document).foundation();
    // });
  }
  return {
    init: init
  };
}());

$(function(){
  if (Airbo.Utils.isAtPage(Airbo.Utils.Pages.TILE_STATS_CHART)) {
    Airbo.TileStatsChart.init();
  }
})
