var Airbo = window.Airbo || {};

Airbo.TilesIndexFilterManager = (function() {
  function init() {
    $(".js-tiles-index-filter-bar").fadeIn();
    initFilterSelect();
  }

  function initFilterSelect() {
    $(".js-filter-option").on("click", function() {
      var key = $(this).data("key");
      var value = $(this).data("value");
      var $container = $("#plan");

      $container.data(key, value);

      console.log($container.data());
    });
  }

  return {
    init: init
  };
})();
