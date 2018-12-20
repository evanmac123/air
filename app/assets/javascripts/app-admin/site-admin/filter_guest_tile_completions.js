var Airbo = window.Airbo || {};

Airbo.GuestTileCompletionGeneration = (function() {
  var filter, form, tiles;

  function displayAllTiles() {
    for (var i = 0; i < tiles.length; i++) {
      tiles[i].style.display = "";
    }
  }

  function filterTiles(value) {
    for (var i = 0; i < tiles.length; i++) {
      var dataset = tiles[i].dataset;
      if (
        dataset.id.includes(value) ||
        dataset.headline.toLowerCase().includes(value) ||
        dataset.status.toLowerCase().includes(value)
      ) {
        tiles[i].style.display = "";
      } else {
        tiles[i].style.display = "none";
      }
    }
  }

  function initTileFilter() {
    filter.keyup(function(e) {
      if (e.target.value) {
        filterTiles(e.target.value.toLowerCase());
      } else {
        displayAllTiles();
      }
    });
  }

  function init() {
    filter = $(".js_filter_guest_tile_completions");
    form = $("#guest_user_tile_completion_form");
    tiles = $(".tile_data_completion_list");
    form.submit(function(event) {
      var confirmation;
      if (form.find("input[type=checkbox]:checked").length === 0) {
        alert("You must select at least one tile to generate a CSV");
        return false;
      } else {
        if (
          confirm(
            "Generate a CSV report for GuestUser completions on the selected tiles?"
          )
        ) {
          return true;
        } else {
          return false;
        }
      }
    });
    initTileFilter();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($("#guest_user_tile_completion_form").length > 0) {
    Airbo.GuestTileCompletionGeneration.init();
  }
});
