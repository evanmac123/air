var Airbo = window.Airbo || {};

Airbo.TileStatsPings = (function() {
  function ping(properties) {
    Airbo.Utils.ping("Tile Stats Action", properties);
  }

  return {
    ping: ping
  };
})();
