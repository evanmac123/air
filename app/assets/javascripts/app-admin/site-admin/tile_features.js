var Airbo = window.Airbo || {};

Airbo.TileFeatures = (function(){

  function init() {
  }

  return {
    init: init
  };
}());

$(function() {
  if ($(".admin-tile_features").length > 0) {
    Airbo.TileFeatures.init();
  }
});
