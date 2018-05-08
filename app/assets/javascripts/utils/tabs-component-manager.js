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
    storeCurrentHash($tab);

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

  function init(initModuleName, defaultTab, initCallback) {
    moduleName = initModuleName;
    callback = initCallback;
    initTabs();
    identifyAndSwitchTab(defaultTab);
  }

  function storeCurrentHash($tab) {
    if ($tab[0].attributes["data-status"] !== undefined) {
      var hash = "#tab-" + $tab[0].attributes["data-status"].nodeValue;
      this.location.hash = hash;
    }
  }

  function identifyAndSwitchTab(defaultTab) {
    var tabIdentifier = this.location.hash.split("#tab-");

    // if URL has hash (data-source identifier of tab), then make that tab active
    // else if defaultTab is present, then make default tab active
    // otherwise defaults to original behavior
    if (tabIdentifier.length > 1) {
      $("li[data-status='" + tabIdentifier[1] + "']").trigger("click");
    } else if (defaultTab) {
      switchToDefaultTab(defaultTab);
    }
  }

  function switchToDefaultTab(defaultTab) {
    $("li[data-status='" + defaultTab + "']").trigger("click");
  }

  return {
    init: init
  };
})();
