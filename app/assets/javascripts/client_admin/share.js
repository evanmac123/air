var Airbo = window.Airbo || {};
Airbo.ClientAdmin = Airbo.ClientAdmin || {};

Airbo.ClientAdmin.Share = (function(){
  function initTabs() {
    $(".js-share-module-tabs li").on("click", function(e) {
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
    $(".js-share-module-tabs li").removeClass("active");
    $(".js-share-module-tab-content").addClass("hidden");
  }

  function showNewTab($tab) {
    $tab.addClass("active");
    var $tabNode = getTabNode($tab);
    $tabNode.removeClass("hidden");
  }

  function getTabNode($tab) {
    return $(".js-share-module-tab-content." + $tab.data("tabContent"));
  }

  function ping(props) {
    var currentUser = $("body").data("currentUser");
    Airbo.Utils.ping("Share Page Action", $.extend(props, currentUser));
  }

  function init() {
    initTabs();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".js-share-module")) {
    Airbo.ClientAdmin.Share.init();
  }
});
