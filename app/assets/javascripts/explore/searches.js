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

    Airbo.SearchTileThumbnail.initTiles()
    Airbo.Utils.ButtonSpinner.reset($(this));
  }

  function bindSearchSubmit() {
    $("#nav-bar-search-submit").on("click", function(e) {
      e.preventDefault();
      $(this).closest("form").submit();
    });

    $("#airbo-search").submit(function(e) {
      var form = $(this);

      validateForm(form);

      if (form.valid()) {
        $(this).children(".search-bar-wrapper").removeClass("error");
        return true;
      } else {
        e.preventDefault();
        $(this).children(".search-bar-wrapper").addClass("error");
      }
    });

    $(".search-bar-input").on("focusout", function(e) {
      $(this).closest(".search-bar-wrapper").removeClass("error");
    });
  }

  function validateForm(form) {
    form.validate({
      rules: {
        query: "required",
      },
      errorPlacement: function(error) {
        return true;
      }
    });
  }

  function init() {
    bindSearchSubmit();
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
