var Airbo = window.Airbo || {};

Airbo.TabsComponentManager = (function() {
  var moduleName;
  var pingAction;
  var callback;

  function initTabs() {
    $(moduleName + "-tabs .tab").on("click", function(e) {
      e.preventDefault();
      switchTabs($(this));
    });
  }

  function switchTabs($tab) {
    ping({ action: "Changed Tab", tab: $tab.text() });

    hideCurrentTab();
    showNewTab($tab);

    if (callback !== undefined) {
      callback();
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

  function ping(props) {
    var currentUser = $("body").data("currentUser");
    Airbo.Utils.ping(pingAction, $.extend(props, currentUser));
  }

  function init(initModuleName, initPingAction, initCallback) {
    moduleName = initModuleName;
    pingAction = initPingAction;
    callback = initCallback;
    initTabs();
  }

  return {
    init: init
  };
})();
