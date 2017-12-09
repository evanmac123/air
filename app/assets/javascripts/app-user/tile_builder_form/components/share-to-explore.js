var Airbo = window.Airbo || {};

Airbo.TileBuilderShareToExplore = (function(){

  function init() {
    $("#tile_is_public").on("click", function() {
      var shared = $(this).is(":checked");

      Airbo.Utils.ping("Tile Builder Action", { action: "Clicked share to Explore checkbox", shared: shared });
    });
  }

  return {
    init: init
  };

}());
