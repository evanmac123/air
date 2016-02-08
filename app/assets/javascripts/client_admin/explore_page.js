var Airbo = window.Airbo || {};

Airbo.ExploreIntro = (function(){
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
  if( $("#explore_intro_modal").length > 0 ) {
    Airbo.ExploreIntro.init();
  }
});