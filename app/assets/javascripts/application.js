var Airbo = window.Airbo || {};
Airbo.Utils = {

  Pages: {
    TILE_BUILDER: "#new_tile_builder_form",
    TILE_STATS_CHART: "#new_tile_stats_chart_form",
    TILE_STATS_GRID: "#tile_stats_grid",
    SURVEY_TABLE: "#survey_table"
  },

  isAtPage: function(identifier){
    return $(identifier).length > 0
  },
}
