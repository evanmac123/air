var Airbo = window.Airbo || {};

Airbo.Search = (function(){

  function addMoreTiles(data) {
    var tilesContainer = $(this).closest(".contextual_tiles_container");
    tilesContainer.data("count", tilesContainer.data("count") + data.added);
    tilesContainer.data("page", data.page);

    if (data.lastBatch === true) {
      $(this).hide();
    }

    var tileGrid = tilesContainer.children(".tiles-row").children().children(".tile-grid");

    tileGrid.append(data.content);

    Airbo.SearchTileThumbnail.initTiles();
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

  function loadResourcesInBackground(content_container, bindCallback) {
    var path = content_container.data("path");

    var count = content_container.data("count");

    var page = parseInt(content_container.data("page")) || 0;
    page++;

    $.ajax({
      url: path,
      data: $.extend(content_container.data(), { page: page }),
      method: 'GET',
      dataType: 'json',
      success: function(data) {
        content_container.data("page", page);
        content_container.data("count", count + data.added);
        content_container.append(data.content);
        bindCallback();
      }
    });
  }

  function init() {
    bindSearchSubmit();
  }

  return {
    init: init,
    loadResourcesInBackground: loadResourcesInBackground
  };

}());

$(function(){
  if( $(".explore-search-results").length > 0 ) {
    Airbo.Search.init();
    Airbo.SearchTabs.init();

    $(".search.tile-grid.explore_tiles").each(function(index, container) {
      Airbo.Search.loadResourcesInBackground($(container), Airbo.CopyTileToBoard.bindThumbnailCopyButton);
    });

    $(".search.tile-grid.client_admin_tiles").each(function(index, container) {
      Airbo.Search.loadResourcesInBackground($(container), Airbo.SearchTileThumbnail.initTiles);
    });
  }
});
