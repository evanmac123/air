var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function() {
  function copyAllTilesPing() {
    var properties = { action: "Clicked Copy All Tiles" };
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function copyTilePing(button, source) {
    var properties = {
      action: "Clicked Copy",
      tile_id: button.data("tileId"),
      section: button.data("section"),
      source: source
    };
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function campaignClickedPing(topic) {
    var properties = {
      action: "Clicked Campaign",
      campaign: topic.data("name"),
      board: topic.data("id")
    };
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function backToExplorePing() {
    var properties = { action: "Clicked Back To Explore" };
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function bindKPIs() {
    $(".topic").on("click", function() {
      campaignClickedPing($(this));
    });

    $("#back-to-explore-link").on("click", function() {
      backToExplorePing($(this));
    });
  }

  function init() {
    bindKPIs();
  }

  return {
    init: init,
    copyTilePing: copyTilePing,
    copyAllTilesPing: copyAllTilesPing
  };
})();

$(function() {
  if ($(".tile_wall_explore").length > 0) {
    Airbo.ExploreKpis.init();
  }
});
