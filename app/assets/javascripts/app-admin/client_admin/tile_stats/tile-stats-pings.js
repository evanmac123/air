var Airbo = window.Airbo || {};

Airbo.TileStatsPings = (function() {
  function ping(properties) {
    var currentUser = $("body").data("currentUser");
    Airbo.Utils.ping("Tile Stats Action", $.extend(properties, currentUser));
  }

  return {
    ping: ping
  };
})();
