var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function(){
  function copyAllTilesPing(currentUserData, button) {
    var properties = $.extend({action: "Clicked" + button.text()}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function copyTilePing(button, source) {
    var currentUserData = $("body").data("currentUser");
    var properties = $.extend({action: "Clicked Copy", tile_id: button.data("tileId"), section: button.data("section"), source: source}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function tileSectionTabsPing(currentUserData, tab) {
    var properties = $.extend({action: "Clicked" + tab.text()}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function bindKPIs(currentUserData) {
    $("#copy-all-tiles-button").on("click", function() {
      copyAllTilesPing(currentUserData, $(this));
    });

    $(".explore_tiles_tab").on("click", function() {
      tileSectionTabsPing(currentUserData, $(this));
    });
  }

  function init() {
    var currentUserData = $("body").data("currentUser");
    bindKPIs(currentUserData);
  }

  return {
    init: init,
    copyTilePing: copyTilePing
  };
}());


$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ExploreKpis.init();
  }
});
