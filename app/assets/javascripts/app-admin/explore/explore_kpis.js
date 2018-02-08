var Airbo = window.Airbo || {};

Airbo.ExploreKpis = (function() {
  var currentUserData;

  function copyAllTilesPing(button) {
    var properties = $.extend(
      { action: "Clicked Copy All Tiles" },
      currentUserData
    );
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function copyTilePing(button, source) {
    var properties = $.extend(
      {
        action: "Clicked Copy",
        tile_id: button.data("tileId"),
        section: button.data("section"),
        source: source
      },
      currentUserData
    );
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function campaignClickedPing(topic) {
    var properties = $.extend(
      {
        action: "Clicked Campaign",
        campaign: topic.data("name"),
        board: topic.data("id")
      },
      currentUserData
    );
    Airbo.Utils.ping("Explore page - Interaction", properties);
  }

  function backToExplorePing(link) {
    var properties = $.extend(
      { action: "Clicked Back To Explore" },
      currentUserData
    );
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
    currentUserData = $("body").data("currentUser");
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
