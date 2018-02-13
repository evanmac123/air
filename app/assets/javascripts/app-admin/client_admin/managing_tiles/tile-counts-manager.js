var Airbo = window.Airbo || {};

Airbo.TileCountsManager = (function() {
  var $moduleContainer;

  function updateTileCounts(event, payload) {
    $moduleContainer.data("tileCounts", payload.tileCounts);
    updateCountsInTabs();

    Airbo.PubSub.publish("updateShareTabNotification", {
      number: payload.tilesToBeSentCount
    });
  }

  function updateCountsInTabs() {
    var tileCounts = $moduleContainer.data("tileCounts");

    $(".js-ca-tiles-index-component-tab .js-tile-count").each(function(
      index,
      el
    ) {
      var $self = $(el);
      var status = $self
        .closest(".js-ca-tiles-index-component-tab")
        .data("status");

      if (tileCounts[status] !== undefined) {
        $self.text("(" + tileCounts[status] + ")");
      } else {
        $self.text("(0)");
      }
    });
  }

  function incrementStatus(status) {
    var tileCounts = $moduleContainer.data("tileCounts");

    if (tileCounts[status] !== undefined) {
      tileCounts[status] += 1;
    } else {
      tileCounts[status] = 1;
    }

    $moduleContainer.data("tileCounts", tileCounts);
  }

  function incrementTileCounts(event, payload) {
    incrementStatus(payload.status);
    updateCountsInTabs();
  }

  function init() {
    $moduleContainer = $(".js-ca-tiles-index-module");
    Airbo.PubSub.subscribe("updateTileCounts", updateTileCounts);
    Airbo.PubSub.subscribe("incrementTileCounts", incrementTileCounts);
  }

  return {
    init: init
  };
})();
