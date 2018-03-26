var Airbo = window.Airbo || {};

Airbo.TilesIndexFilterManager = (function() {
  function init() {
    $(".js-tiles-index-filter-bar").fadeIn();
    initFilterSelect();
  }

  function initFilterSelect() {
    $(".js-filter-option").on("click", function() {
      var container = $(this)
        .closest(".js-tiles-index-filter-bar")
        .data("tilesIndexContainer");

      filterData($(this), $(container));
    });
  }

  function filterData($filter, $container) {
    var key = $filter.data("key");
    var filterParam = $filter.data("value");

    if ($container.data(key) !== filterParam) {
      $container.data(key, filterParam);
      filterSpecificConfigs(key, filterParam, $container);
      Airbo.TilesIndexLoader.resetTiles($container);
    }
  }

  function filterSpecificConfigs(key, filterParam, $container) {
    if (key === "sort") {
      if (filterParam === "position") {
        $container.sortable("enable");
      } else {
        $container.sortable("disable");
      }
    }
  }

  return {
    init: init
  };
})();
