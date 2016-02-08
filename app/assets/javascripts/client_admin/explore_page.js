var Airbo = window.Airbo || {};

Airbo.Explore = (function(){
  var modalObj = Airbo.Utils.StandardModal();
  function initModalObj() {
    modalObj.init({
      modalId: "explore_intro_modal",
      closeSel: ".close_explore_intro",
      onOpenedEvent: function() {
        $(document).foundation();
      }
    });
  }
  function init() {
    initModalObj();
    modalObj.open();
  }
  return {
    init: init
  }
}());

$(document).ready(function(){
  Airbo.Explore.init();
});