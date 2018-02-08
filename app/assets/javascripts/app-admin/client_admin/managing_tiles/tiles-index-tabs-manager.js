var Airbo = window.Airbo || {};

Airbo.TilesIndexTabManager = (function() {
  function init() {
    Airbo.TabsComponentManager.init(".js-ca-tiles-index-module");
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-ca-tiles-index-module")) {
    Airbo.TilesIndexTabManager.init();
  }
});
