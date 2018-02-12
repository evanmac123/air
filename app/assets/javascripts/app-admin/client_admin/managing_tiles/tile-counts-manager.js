var Airbo = window.Airbo || {};

Airbo.TileCountsManager = (function() {
  function updateTileCounts(event, payload) {
    var tileCounts = payload.tileCounts;

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

  function init() {
    Airbo.PubSub.subscribe("updateTileCounts", updateTileCounts);
  }

  return {
    init: init
  };
})();
