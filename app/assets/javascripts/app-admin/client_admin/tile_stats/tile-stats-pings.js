var Airbo = window.Airbo || {};

Airbo.TileStatsPings = (function() {
  function ping(properties) {
    Airbo.Utils.ping("Tile Stats Action", $.extend(properties));
  }

  return {
    ping: ping
  };
})();
