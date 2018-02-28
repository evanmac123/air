var Airbo = window.Airbo || {};

Airbo.TabsComponentManager = (function() {
  var moduleName;
  var callback;

  function initTabs() {
    $(moduleName + "-tabs .tab").on("click", function(e) {
      e.preventDefault();
      switchTabs($(this));
    });
  }

  function switchTabs($tab) {
    hideCurrentTab();
    showNewTab($tab);

    if (callback !== undefined) {
      callback($tab);
    }
  }

  function hideCurrentTab() {
    $(moduleName + "-tabs li").removeClass("active");
    $(moduleName + "-tab-content").addClass("hidden");
  }

  function showNewTab($tab) {
    $tab.addClass("active");
    var $tabNode = getTabNode($tab);
    $tabNode.removeClass("hidden");
  }

  function getTabNode($tab) {
    return $(moduleName + "-tab-content." + $tab.data("tabContent"));
  }

  function init(initModuleName, initCallback) {
    moduleName = initModuleName;
    callback = initCallback;
    initTabs();
  }

  return {
    init: init
  };
})();
