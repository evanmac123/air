var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function(){
  var currentUserData;

  function copyAllTilesPing(button) {
    var properties = $.extend({ action: "Clicked Copy All Tiles" }, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function copyTilePing(button, source) {
    var properties = $.extend({ action: "Clicked Copy", tile_id: button.data("tileId"), section: button.data("section"), source: source }, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function tileSectionTabsPing(tab) {
    var properties = $.extend({ action: "Clicked " + tab.text() }, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function collectionClickedPing(topic) {
    var properties = $.extend({ action: "Clicked Collection", collection: topic.data("name"), board: topic.data("id") }, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function backToExplorePing(link) {
    var properties = $.extend({action: "Clicked Back To Explore"}, currentUserData);
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function viewedExplorePing() {
    var properties = $.extend({ page_name: "explore" }, currentUserData);
    Airbo.Utils.ping("viewed page", properties);

    if ( $(".client_admin-collections").length > 0) {
      viewedCollectionPing();
    }
  }

  function viewedCollectionPing() {
    var properties = $.extend({ page_name: "explore collection", collection: $(".explores").data("collectionId")}, currentUserData);
    Airbo.Utils.ping("viewed page", properties);
  }

  function bindKPIs() {
    $(".explore_tiles_tab").on("click", function() {
      tileSectionTabsPing($(this));
    });

    $(".topic").on("click", function() {
      collectionClickedPing($(this));
    });

    $("#back-to-explore-link").on("click", function() {
      backToExplorePing($(this));
    });
  }

  function init() {
    currentUserData = $("body").data("currentUser");
    viewedExplorePing();
    bindKPIs();
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
