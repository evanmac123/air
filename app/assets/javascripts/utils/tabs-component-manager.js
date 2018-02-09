var Airbo = window.Airbo || {};

Airbo.TabsComponentManager = (function() {
  var moduleName;
  var pingAction;

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

  function init(initModuleName, initPingAction) {
    moduleName = initModuleName;
    pingAction = initPingAction;
    initTabs();
  }

  return {
    init: init
  };
})();
