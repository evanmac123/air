var Airbo = window.Airbo || {};

Airbo.TilesIndexTabManager = (function() {
  function init() {
    Airbo.TabsComponentManager.init(
      ".js-ca-tiles-index-module",
      "Edit page action",
      changeTabsCallback
    );
  }

  function changeTabsCallback() {
    manageDownloadStatsButton();
  }

  function manageDownloadStatsButton() {
    var $button = $(".download-stats-button");
    var path = $(".js-ca-tiles-index-module-tab-content:visible").data(
      "statsLink"
    );

    $button.hide();
    $button.attr("href", path);

    if (path.length > 0) {
      $button.show();
    }
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-ca-tiles-index-module")) {
    Airbo.TilesIndexTabManager.init();
  }
});
