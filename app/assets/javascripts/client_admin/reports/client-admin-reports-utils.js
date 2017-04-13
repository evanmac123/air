var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsUtils = (function(){
  var reportSel = ".report-container";

  function switchActiveTab($node) {
    $node.siblings().removeClass("tabs-component-active");
    $node.addClass("tabs-component-active");
  }

  return {
    switchActiveTab: switchActiveTab
  };

}());
