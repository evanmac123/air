var Airbo = window.Airbo || {};

Airbo.TilesIndexTabManager = (function() {
  function init() {
    Airbo.TabsComponentManager.init(
      ".js-ca-tiles-index-module",
      "Edit page action",
      changeTabsCallback
    );
  }

  function changeTabsCallback($tab) {
    manageDownloadStatsButton($tab);
    manageSuggestionBoxAccessButton($tab);
  }

  function manageDownloadStatsButton($tab) {
    var $button = $(".download-stats-button");
    var path = $tab.data("statsLink");

    $button.hide();
    $button.attr("href", path);

    if (path !== undefined) {
      $button.show();
    }
  }

  function manageSuggestionBoxAccessButton($tab) {
    var $button = $(".js-suggestion-box-manage-access");
    $button.hide();

    if ($tab.data("showSuggestionBoxControls") === true) {
      $button.show();
    }
  }

  return {
    init: init
  };
})();
