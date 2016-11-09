var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function(){
  function copyAllTilesPing(button) {
    var currentUserData = $("body").data("currentUser");
    var properties = $.extend({action: "Clicked Copy All Tiles"}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function copyTilePing(button, source) {
    var currentUserData = $("body").data("currentUser");
    var properties = $.extend({action: "Clicked Copy", tile_id: button.data("tileId"), section: button.data("section"), source: source}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function tileSectionTabsPing(currentUserData, tab) {
    var properties = $.extend({action: "Clicked " + tab.text()}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function collectionClickedPing(currentUserData, topic) {
    var properties = $.extend({action: "Clicked Collection", collection: topic.data("name"), board: topic.data("id")}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function backToExplorePing(currentUserData, link) {
    var properties = $.extend({action: "Clicked Back To Explore"}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function bindKPIs(currentUserData) {
    $(".explore_tiles_tab").on("click", function() {
      tileSectionTabsPing(currentUserData, $(this));
    });

    $(".topic").on("click", function() {
      collectionClickedPing(currentUserData, $(this));
    });

    $("#back-to-explore-link").on("click", function() {
      backToExplorePing(currentUserData, $(this));
    });
  }

  function init() {
    var currentUserData = $("body").data("currentUser");
    bindKPIs(currentUserData);
  }

  return {
    init: init,
    copyTilePing: copyTilePing,
    copyAllTilesPing: copyAllTilesPing
  };
}());


$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ExploreKpis.init();
  }
});
