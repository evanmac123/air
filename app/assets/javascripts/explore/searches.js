var Airbo = window.Airbo || {};

Airbo.Search = (function(){

  function bindMoreTilesButtons() {
    $(".show-more-tiles-button").each(function() {
      bindMoreTilesButton($(this));
    });
  }

  function bindMoreTilesButton(button) {
    button.on("click", function(e) {
      e.preventDefault();
      Airbo.Utils.ButtonSpinner.trigger($(this));
      var tilesContainer = $(this).closest(".contextual_tiles_container");
      var params = tilesContainer.data();
      params.page++;

      $.get(params.moreTilesPath, params, addMoreTiles.bind(this));
    });
  }

  function addMoreTiles(data) {
    var tilesContainer = $(this).closest(".contextual_tiles_container");
    tilesContainer.data("count", tilesContainer.data("count") + data.added);
    tilesContainer.data("page", data.page);

    if (data.lastBatch === true) {
      $(this).hide();
    }

    var tileGrid = tilesContainer.children(".tiles-row").children().children(".tile-grid");

    tileGrid.append(data.content);
    Airbo.Utils.ButtonSpinner.reset($(this));
  }

  function init() {
    bindMoreTilesButtons();
  }

  return {
    init: init
  };

}());

$(function(){
  if( $(".explore-search-results").length > 0 ) {
    Airbo.Search.init();
  }
});
