var Airbo = window.Airbo || {};

Airbo.TileModalUtils = (function(){
  function tileContainerSizes() {
    tileContainer = $(".tile_full_image:visible")[0];
    if (tileContainer) {
      return tileContainer.getBoundingClientRect();
    }
  }

  return {
    tileContainerSizes: tileContainerSizes
  };

}());
