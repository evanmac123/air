var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function(){
  function copyAllTilesPing(currentUserData, button) {
    var properties = $.extend({action: "Clicked" + button.text()}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function copyTilePing(currentUserData, button) {
    var properties = $.extend({action: "Clicked" + button.text(), tile_id: button.data("tileId"), section: button.data("section")}, currentUserData);
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

    $(".explore_copy_link").on("click", function() {
      copyTilePing(currentUserData, $(this));
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
    init: init
  };
}());


$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ExploreKpis.init();
  }
});
